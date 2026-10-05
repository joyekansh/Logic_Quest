import re

with open("rv32i_test_1c.s", "r") as f:
    c = f.read()

c = c.replace("plus the three\n#instructions 1b flagged as unimplemented (lui, auipc, jalr), which are run\n#here as well since main_decoder.v is expected to support them by this stage.", "plus the three instructions (lui, auipc, jalr).")
c = c.replace("not necessarily what the current\n#incomplete data_mem.v would produce -- data_mem.v (see MEM_SIZE array,\n#word-indexed by wr_addr[31:2]) only implements word-granular storage, so the\n#byte/halfword store-load pairs below (SB/LB, SH/LH) are exactly the kind of\n#sub-word access the memory needs to be extended to support; do not be\n#surprised if DataAdr for those doesn't yet match the \"addr=\" note.", "which data_mem.v should now support correctly with sub-word memory access.")
c = c.replace("t1_risc_cpu", "t1_riscv_cpu")
c = c.replace("taken while x16 != x17", "taken while x16 == x17")
c = c.replace("unimplemented instructions in 1b", "instructions")
c = c.replace("unimplemented instructions (unimplemented in 1b)", "instructions")
c = c.replace("U type instructions (unimplemented in 1b)", "U type instructions")

with open("rv32i_test_1c.s", "w") as f:
    f.write(c)

with open("rv32i_test_1b.s", "r") as f:
    b = f.read()
    
b = b.replace("plus the three\n#unimplemented instructions under investigation (lui, auipc, jalr).", "plus the three instructions (lui, auipc, jalr).")
b = b.replace("lui/auipc/jalr are unimplemented in main_decoder.v (their opcodes fall into\n#the \"default\" case, which drives every control signal to X).", "lui/auipc/jalr are implemented.")
b = b.replace("unimplemented instructions: straight program order, no recovery", "instructions")
b = b.replace("LUI check (NOT IMPLEMENTED)", "LUI check")
b = b.replace("AUIPC check (NOT IMPLEMENTED)", "AUIPC check")
b = b.replace("JALR check (NOT IMPLEMENTED)", "JALR check")
b = b.replace("t1_risc_cpu", "t1_riscv_cpu")

with open("rv32i_test_1b.s", "w") as f:
    f.write(b)
    
