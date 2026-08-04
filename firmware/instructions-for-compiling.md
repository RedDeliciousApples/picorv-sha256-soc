After editing [main.c](firmware/main.c) as needed, run:
```
riscv32-unknown-elf-gcc \
  -march=rv32i \
  -mabi=ilp32 \
  -nostdlib \
  -nostartfiles \
  -ffreestanding \
  -T linker.ld \
  start.S main.c \
  -o firmware.elf
```
to compile, then convert to binary using:
```
riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
```
then convert to a .mem file:
```bash
python firmware/bin_to_mem.py
```
