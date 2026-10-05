
// main_decoder.v - logic for main decoder (full RV32I)

module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,         // 3-bit: 000=I, 001=S, 010=B, 011=J, 100=U
    output [1:0] ALUOp,
    output       IsLUI, IsAUIPC, IsJALR,
    output [2:0] BranchType      // encodes which branch condition (funct3 of B-type)
);

reg [12:0] controls;   // RegWrite_ImmSrc(3)_ALUSrc_MemWrite_ResultSrc(2)_Branch_ALUOp(2)_Jump
                       //  [12]  [11:9]    [8]    [7]      [6:5]       [4]   [3:2]  [1]
// Bits: {RegWrite, ImmSrc[2:0], ALUSrc, MemWrite, ResultSrc[1:0], Branch, ALUOp[1:0], Jump}
// Total = 1+3+1+1+2+1+2+1 = 12 bits  -> use 13 bits for safety

always @(*) begin
    case (op)
        // lw
        7'b0000011: controls = 13'b1_000_1_0_01_0_00_0;
        // sw
        7'b0100011: controls = 13'b0_001_1_1_00_0_00_0;
        // R-type
        7'b0110011: controls = 13'b1_000_0_0_00_0_10_0;
        // B-type (all branches share same decode; BranchType from funct3)
        7'b1100011: controls = 13'b0_010_0_0_00_1_01_0;
        // I-type ALU (addi, slti, etc.)
        7'b0010011: controls = 13'b1_000_1_0_00_0_10_0;
        // jal
        7'b1101111: controls = 13'b1_011_0_0_10_0_00_1;
        // lui
        7'b0110111: controls = 13'b1_100_0_0_00_0_00_0;
        // auipc
        7'b0010111: controls = 13'b1_100_1_0_00_0_00_0;
        // jalr
        7'b1100111: controls = 13'b1_000_1_0_10_0_00_1;
        default:    controls = 13'bx_xxx_x_x_xx_x_xx_x;
    endcase
end

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

// LUI: write U-immediate directly to rd (no ALU operation)
assign IsLUI   = (op == 7'b0110111);
// AUIPC: PC + U-immediate
assign IsAUIPC = (op == 7'b0010111);
// JALR: jump-and-link register (uses I-immediate + rs1)
assign IsJALR  = (op == 7'b1100111);

// BranchType from funct3 — only meaningful when Branch=1
assign BranchType = funct3;

endmodule

