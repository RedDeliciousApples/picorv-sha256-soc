from pathlib import Path

data = Path("firmware.bin").read_bytes()

# Pad to a multiple of 4 bytes
while len(data) % 4 != 0:
    data += b"\x00"

with open("memory.mem", "w") as f:
    for i in range(0, len(data), 4):
        word = data[i:i+4]

        # RISC-V is little-endian, but $readmemh loads each line as a 32-bit word.
        value = int.from_bytes(word, byteorder="little")

        f.write(f"{value:08x}\n")
