import os
import subprocess
import sys
import struct

def assemble(asm_file, hex_file):
    obj_file = "temp.o"
    bin_file = "temp.bin"
    
    # Run assembler
    subprocess.run(["riscv64-unknown-elf-as", "-march=rv32i", "-mabi=ilp32", asm_file, "-o", obj_file], check=True)
    
    # Run objcopy to get flat binary
    subprocess.run(["riscv64-unknown-elf-objcopy", "-O", "binary", obj_file, bin_file], check=True)
    
    # Read binary and output hex
    with open(bin_file, "rb") as f:
        data = f.read()
        
    with open(hex_file, "w") as f:
        for i in range(0, len(data), 4):
            word = data[i:i+4]
            if len(word) < 4:
                word += b'\x00' * (4 - len(word))
            val = struct.unpack("<I", word)[0]
            f.write(f"{val:08x}\n")
            
    os.remove(obj_file)
    os.remove(bin_file)

if __name__ == "__main__":
    assemble(sys.argv[1], sys.argv[2])
