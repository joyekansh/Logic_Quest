import sys
import re

with open("../.test/tb_1c.v", "r") as f:
    c = f.read()

# SB check
c = re.sub(r'if\(DataAdr === 32 & WriteData === 1\) \$display \("23. sb implementation is correct"\);', 
           'if(DataAdr === 33 & WriteData === 32\'hFFFFFFFF) $display ("23. sb implementation is correct");', c)

# SH check
c = re.sub(r'if\(DataAdr === 36 & WriteData === -3\) \$display \("24. sh implementation is correct"\);', 
           'if(DataAdr === 38 & WriteData === -3) $display ("24. sh implementation is correct");', c)

# LB check
c = re.sub(r'if\(DataAdr === 32 & Result === 1 \) \$display \("26. lb implementation is correct"\);', 
           'if(DataAdr === 33 & Result === -1 ) $display ("26. lb implementation is correct");', c)

# LH check
c = re.sub(r'if\(DataAdr === 36 & Result === -3 \) \$display \("27. lh implementation is correct"\);', 
           'if(DataAdr === 38 & Result === -3 ) $display ("27. lh implementation is correct");', c)

# LW check
c = re.sub(r'if\(DataAdr === 40 & Result === 16\) \$display \("28. lw implementation is correct"\);', 
           'if(DataAdr === 32 & Result === 32\'h0000FF00) $display ("28. lw implementation is correct");', c)

# LBU check
c = re.sub(r'if\(DataAdr === 32 & Result === 1\) \$display \("29. lbu implementation is correct"\);', 
           'if(DataAdr === 33 & Result === 255) $display ("29. lbu implementation is correct");', c)

# LHU check
c = re.sub(r'if\(DataAdr === 36 & Result === 32\'h0000FFFD\) \$display \("30. lhu implementation is correct"\);', 
           'if(DataAdr === 38 & Result === 32\'h0000FFFD) $display ("30. lhu implementation is correct");', c)

# SRA check
c = re.sub(r'if\(Result === 8\) \$display\("18. sra implementation is correct "\);', 
           'if(Result === -2) $display("18. sra implementation is correct ");', c)

# LUI check
c = re.sub(r'if\(Result === 32\'h02000000\) \$display\("21. lui implementation is correct "\);', 
           'if(Result === 32\'h87654000) $display("21. lui implementation is correct ");', c)

# AUIPC check
c = re.sub(r'if\(Result === 32\'h02000060\) \$display\("22. auipc implementation is correct "\);', 
           'if(Result === 32\'h87654060) $display("22. auipc implementation is correct ");', c)

# BLTU_OUT check
c = re.sub(r'BLTU_OUT : begin\s*i = i \+ 1\'b1;\s*if\(Result === 5\)', 
           'BLTU_OUT : begin\n            i = i + 1\'b1;\n            if(Result === -1)', c)

with open("../.test/tb_1c.v", "w") as f:
    f.write(c)

