
// riscv_cpu.v - single-cycle RISC-V CPU Processor (full RV32I)

module riscv_cpu (
    input         clk, reset,
    output [31:0] PC,
    input  [31:0] Instr,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire        ALUSrc, RegWrite, Jump;
wire        Zero, Negative, Less, LessU;
wire [1:0]  ResultSrc;
wire [2:0]  ImmSrc;       // 3-bit
wire [3:0]  ALUControl;   // 4-bit
wire        IsLUI, IsAUIPC, IsJALR;
wire [2:0]  funct3_ctrl;
wire        PCSrc;
wire        MemWrite_int;

// Narrow-store RMW wires (computed inside datapath)
wire        MemWrite_byte;
wire [31:0] Mem_WrData_rmw, Mem_WrAddr_rmw;
wire [31:0] Mem_WrAddr_int, Mem_WrData_int;

controller c (
    Instr[6:0], Instr[14:12], Instr[30],
    Zero, Negative, Less, LessU,
    ResultSrc, MemWrite_int, PCSrc, ALUSrc, RegWrite, Jump,
    ImmSrc, ALUControl, IsLUI, IsAUIPC, funct3_ctrl, IsJALR
);

datapath dp (
    clk, reset, ResultSrc, PCSrc,
    ALUSrc, RegWrite, ImmSrc, ALUControl,
    IsLUI, IsAUIPC, IsJALR, funct3_ctrl,
    Zero, Negative, Less, LessU,
    PC, Instr, Mem_WrAddr_int, Mem_WrData_int,
    ReadData, Result,
    MemWrite_byte, Mem_WrData_rmw, Mem_WrAddr_rmw
);

// For SB/SH: use the RMW word and word-aligned address;
// For SW: use the original ALU-computed address and write data.
assign MemWrite  = MemWrite_int;
assign Mem_WrAddr = MemWrite_byte ? Mem_WrAddr_rmw : Mem_WrAddr_int;
assign Mem_WrData = MemWrite_byte ? Mem_WrData_rmw : Mem_WrData_int;

endmodule

