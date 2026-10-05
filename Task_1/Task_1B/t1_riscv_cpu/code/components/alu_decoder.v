
// alu_decoder.v - logic for ALU decoder (full RV32I)

// ALUControl encoding (4-bit):
//  4'b0000 : ADD
//  4'b0001 : SUB
//  4'b0010 : AND
//  4'b0011 : OR
//  4'b0100 : XOR
//  4'b0101 : SLT  (signed less-than)
//  4'b0110 : SLTU (unsigned less-than)
//  4'b0111 : SLL  (shift left logical)
//  4'b1000 : SRL  (shift right logical)
//  4'b1001 : SRA  (shift right arithmetic)

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0000;   // lw/sw: addition for address calc
        2'b01: ALUControl = 4'b0001;   // beq: subtraction for comparison
        default: begin  // R-type or I-type ALU: decode from funct3/funct7
            case (funct3)
                3'b000: begin
                    // ADD/ADDI vs SUB (R-type only, funct7b5=1 and opb5=1)
                    if (funct7b5 & opb5) ALUControl = 4'b0001; // sub
                    else                  ALUControl = 4'b0000; // add, addi
                end
                3'b001: ALUControl = 4'b0111;  // sll, slli
                3'b010: ALUControl = 4'b0101;  // slt, slti
                3'b011: ALUControl = 4'b0110;  // sltu, sltiu
                3'b100: ALUControl = 4'b0100;  // xor, xori
                3'b101: begin
                    // SRL/SRLI vs SRA/SRAI: funct7b5 distinguishes
                    if (funct7b5) ALUControl = 4'b1001; // sra, srai
                    else          ALUControl = 4'b1000; // srl, srli
                end
                3'b110: ALUControl = 4'b0011;  // or, ori
                3'b111: ALUControl = 4'b0010;  // and, andi
            endcase
        end
    endcase
end

endmodule

