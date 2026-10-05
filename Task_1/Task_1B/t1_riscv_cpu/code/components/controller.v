
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, Negative, Less, LessU,   // ALU flags for branch resolution
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,                         // 3-bit to support U-type
    output [3:0] ALUControl,                     // 4-bit for full RV32I ALU ops
    output       IsLUI, IsAUIPC,                 // special datapath mux selects
    output [2:0] funct3_out,                     // pass funct3 to datapath for mem ops
    output       IsJALR                          // JALR select for datapath
);

wire [1:0] ALUOp;
wire       Branch;
wire [2:0] BranchType;    // encodes which branch condition to check

main_decoder    md (op, funct3, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp,
                    IsLUI, IsAUIPC, IsJALR, BranchType);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// Branch condition resolution
reg branch_taken;
always @(*) begin
    case (BranchType)
        3'b000: branch_taken = Zero;                    // BEQ
        3'b001: branch_taken = ~Zero;                   // BNE
        3'b100: branch_taken = Less;                    // BLT  (signed)
        3'b101: branch_taken = ~Less & ~Zero;           // BGE  (signed, i.e. >=)
        3'b110: branch_taken = LessU;                   // BLTU (unsigned)
        3'b111: branch_taken = ~LessU & ~Zero;          // BGEU (unsigned)
        default: branch_taken = 1'b0;
    endcase
end

assign PCSrc   = (Branch & branch_taken) | Jump;
assign funct3_out = funct3;

endmodule

