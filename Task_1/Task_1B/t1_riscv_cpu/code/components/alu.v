
// alu.v - ALU module (full RV32I)

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,        // operands
    input       [3:0] alu_ctrl,          // ALU control (4-bit for full RV32I)
    output reg  [WIDTH-1:0] alu_out,     // ALU output
    output      zero,                    // zero flag
    output      negative,                // sign bit
    output      less,                    // signed less-than  (SLT result)
    output      lessU                    // unsigned less-than (SLTU result)
);

// Shift amount: lower 5 bits of b
wire [4:0] shamt = b[4:0];

always @(a, b, alu_ctrl) begin
    case (alu_ctrl)
        4'b0000: alu_out <= a + b;                           // ADD
        4'b0001: alu_out <= a - b;                           // SUB
        4'b0010: alu_out <= a & b;                           // AND
        4'b0011: alu_out <= a | b;                           // OR
        4'b0100: alu_out <= a ^ b;                           // XOR
        4'b0101: begin                                       // SLT (signed)
            if (a[WIDTH-1] != b[WIDTH-1])
                alu_out <= a[WIDTH-1] ? 32'd1 : 32'd0;     // a negative -> a < b
            else
                alu_out <= (a < b) ? 32'd1 : 32'd0;
        end
        4'b0110: alu_out <= (a < b) ? 32'd1 : 32'd0;       // SLTU (unsigned)
        4'b0111: alu_out <= a << shamt;                     // SLL
        4'b1000: alu_out <= a >> shamt;                     // SRL (logical)
        4'b1001: alu_out <= $signed(a) >>> shamt;           // SRA (arithmetic)
        default: alu_out <= {WIDTH{1'b0}};
    endcase
end

// Flags
assign zero     = (alu_out == {WIDTH{1'b0}});
assign negative = alu_out[WIDTH-1];

// Signed less-than: a < b (signed)
assign less  = ($signed(a) < $signed(b));

// Unsigned less-than: a < b (unsigned)
assign lessU = (a < b);

endmodule

