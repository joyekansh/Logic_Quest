import sys
import re

# Fix rv32i_test_1c.s
with open("rv32i_test_1c.s", "r") as f:
    c = f.read()

c = c.replace("addi    x4, x0, 0                    # x4 = 0 (scratch, reused by loops)", "addi    x4, x0, -1                   # x4 = -1 (scratch, reused by loops)")
c = c.replace("sb      x1, 16(x2)", "sb      x4, 17(x2)")
c = c.replace("sh      x3, 20(x2)", "sh      x3, 22(x2)")

c = c.replace("lb      x26, 35(x3)", "lb      x26, 36(x3)")
c = c.replace("lh      x27, 39(x3)", "lh      x27, 41(x3)")
c = c.replace("lw      x28, 43(x3)", "lw      x28, 35(x3)")
c = c.replace("lbu     x29, 35(x3)", "lbu     x29, 36(x3)")
c = c.replace("lhu     x30, 39(x3)", "lhu     x30, 41(x3)")

c = c.replace("sra     x21, x2, x1", "sra     x21, x3, x1")
c = c.replace("jalr    x31, 0x134(x0)", "jalr    x31, 0x135(x0)")
c = c.replace("lui     x24, 0x2000", "lui     x24, 0x87654")
c = c.replace("auipc   x25, 0x2000", "auipc   x25, 0x87654")

c = c.replace("addi    x10, x0, 1", "addi    x10, x0, -5")
c = c.replace("addi    x11, x0, 5", "addi    x11, x0, -1")

c = c.replace("addi    x12, x0, 1", "addi    x12, x0, -5")
c = c.replace("addi    x13, x0, 5", "addi    x13, x0, -1")

with open("rv32i_test_1c.s", "w") as f:
    f.write(c)

# Fix rv32i_test_1b.s
with open("rv32i_test_1b.s", "r") as f:
    b = f.read()

# Add end loop
if "self:       beq     x0, x0, self" not in b:
    b = b.replace("            addi    x0, x0, 0                    # padding (only reached if jalr     60\n                                                  # actually worked and jumped here)", 
                  "            addi    x0, x0, 0                    # padding (only reached if jalr     60\n                                                  # actually worked and jumped here)\nself:       beq     x0, x0, self                 # infinite loop                           64")

with open("rv32i_test_1b.s", "w") as f:
    f.write(b)
