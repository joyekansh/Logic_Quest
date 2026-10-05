
// datapath.v - full RV32I single-cycle datapath

module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [2:0]   ImmSrc,         // 3-bit
    input [3:0]   ALUControl,     // 4-bit
    input         IsLUI,          // LUI: write U-imm directly
    input         IsAUIPC,        // AUIPC: PC + U-imm
    input         IsJALR,         // JALR: jump target = rs1 + imm
    input [2:0]   funct3,         // memory access width + branch type
    output        Zero, Negative, Less, LessU,  // ALU flags to controller
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,       // word from data_mem
    output [31:0] Result,
    // byte/halfword write support (read-modify-write outputs)
    output        MemWrite_byte,  // narrower-than-word write enable
    output [31:0] Mem_WrData_rmw, // modified word for narrow stores
    output [31:0] Mem_WrAddr_rmw  // same address as Mem_WrAddr (word-aligned)
);

wire [31:0] PCNext, PCPlus4, PCTarget, PCTargetJALR;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
wire [31:0] WriteBackData;  // final value written to register file

// -------------------------------------------------------------------------
// PC logic
// -------------------------------------------------------------------------
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);

// JALR: target = (rs1 + sign-ext-imm) & ~1
wire [31:0] JALR_target;
assign JALR_target = (SrcA + ImmExt) & 32'hFFFFFFFE;

// PC next mux:
//   PCSrc=1, IsJALR=1  -> JALR_target
//   PCSrc=1, IsJALR=0  -> PCTarget (branch / JAL)
//   PCSrc=0            -> PCPlus4
wire [31:0] branch_or_jalr_target;
mux2 #(32) jalrmux(PCTarget, JALR_target, IsJALR, branch_or_jalr_target);
mux2 #(32) pcmux(PCPlus4, branch_or_jalr_target, PCSrc, PCNext);

// -------------------------------------------------------------------------
// Register file
// -------------------------------------------------------------------------
reg_file rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7],
             WriteBackData, SrcA, WriteData);

imm_extend ext (Instr[31:7], ImmSrc, ImmExt);

// -------------------------------------------------------------------------
// ALU
// -------------------------------------------------------------------------
mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);

// AUIPC uses PC as SrcA (not register rs1).
// We mux SrcA for AUIPC: SrcA_alu = IsAUIPC ? PC : SrcA
wire [31:0] SrcA_alu;
mux2 #(32) auipcmux(SrcA, PC, IsAUIPC, SrcA_alu);

alu alu_inst (SrcA_alu, SrcB, ALUControl, ALUResult,
              Zero, Negative, Less, LessU);

// -------------------------------------------------------------------------
// Load data: byte/halfword sign/zero extension from word-aligned read
// -------------------------------------------------------------------------
wire [1:0] byte_offset = ALUResult[1:0];
wire [31:0] load_data;

// Extract byte/halfword from the 32-bit word read from memory
wire [7:0]  loaded_byte  = (byte_offset == 2'b00) ? ReadData[7:0]   :
                           (byte_offset == 2'b01) ? ReadData[15:8]  :
                           (byte_offset == 2'b10) ? ReadData[23:16] :
                                                    ReadData[31:24];
wire [15:0] loaded_half  = (byte_offset[1] == 1'b0) ? ReadData[15:0] :
                                                       ReadData[31:16];

// funct3 for load: 000=LB 001=LH 010=LW 100=LBU 101=LHU
assign load_data =
    (funct3 == 3'b000) ? {{24{loaded_byte[7]}}, loaded_byte}      : // LB
    (funct3 == 3'b001) ? {{16{loaded_half[15]}}, loaded_half}     : // LH
    (funct3 == 3'b010) ? ReadData                                  : // LW
    (funct3 == 3'b100) ? {24'b0, loaded_byte}                     : // LBU
    (funct3 == 3'b101) ? {16'b0, loaded_half}                     : // LHU
                         ReadData;                                   // default LW

// -------------------------------------------------------------------------
// Result mux:
//   ResultSrc 00 -> ALUResult
//   ResultSrc 01 -> load_data  (LW/LB/LH/LBU/LHU)
//   ResultSrc 10 -> PCPlus4    (JAL/JALR link address)
// -------------------------------------------------------------------------
wire [31:0] ResultMux;
mux3 #(32) resultmux(ALUResult, load_data, PCPlus4, ResultSrc, ResultMux);

// -------------------------------------------------------------------------
// LUI: write-back = U-immediate (bypass ALU entirely)
// -------------------------------------------------------------------------
mux2 #(32) luimux(ResultMux, ImmExt, IsLUI, WriteBackData);

assign Result = WriteBackData;

// -------------------------------------------------------------------------
// Store outputs
// -------------------------------------------------------------------------
assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

// Narrow store: read-modify-write for SB / SH
// (The CPU drives Mem_WrData_rmw; the top module routes it)
// funct3 for store: 000=SB 001=SH 010=SW
wire [31:0] word_in_mem = ReadData;   // word from data_mem at aligned addr

reg [31:0] rmw_word;
always @(*) begin
    rmw_word = word_in_mem;
    case (funct3)
        3'b000: begin  // SB
            case (byte_offset)
                2'b00: rmw_word[7:0]   = WriteData[7:0];
                2'b01: rmw_word[15:8]  = WriteData[7:0];
                2'b10: rmw_word[23:16] = WriteData[7:0];
                2'b11: rmw_word[31:24] = WriteData[7:0];
            endcase
        end
        3'b001: begin  // SH
            if (byte_offset[1])
                rmw_word[31:16] = WriteData[15:0];
            else
                rmw_word[15:0]  = WriteData[15:0];
        end
        default: rmw_word = WriteData;  // SW: full word
    endcase
end

assign Mem_WrData_rmw = rmw_word;
assign Mem_WrAddr_rmw = {ALUResult[31:2], 2'b00};  // word-aligned
// MemWrite_byte not used by data_mem directly (SW path handles enable externally)
assign MemWrite_byte  = (funct3 == 3'b000 || funct3 == 3'b001);

endmodule

