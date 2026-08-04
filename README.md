# PicoRV32 SHA-256 SoC

## Overview
This is a PicoRV32-based RV32I SoC with a memory-mapped SHA-256 peripheral, using the AXI-4 Lite interface, mainly made to help me learn AXI. It hasn't been optimized for performance yet, but it can process a 512-bit padded message each operation.

![Level 1 diagram](docs/images/level1diagram.png)

## Current Status
Works with a 512-bit block, all tests pass. 

## Architecture
![Level 2 diagram](docs/images/level2diagram.png)

## SHA-256 Peripheral Internals
![Level 3 diagram](docs/images/level3diagram.png)

## Memory Map
| Memory Region | Purpose |
|----------|----------------------:|
|0x0000_0000 - 0x0000_FFFF |  64 KiB AXI RAM |
|0x1000_0000 - 0x1000_00FF |  SHA-256 peripheral |

See the [memory map documentation](docs/memory_map.md) for more details.

## SHA Peripheral Programming Model
1. Write `BLOCK0` through `BLOCK15`.
2. Write `CTRL[0] = 1`.
3. Poll `STATUS.done`.
4. Read `DIGEST0` through `DIGEST7`.

## Building Firmware
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
There's a copy of this in [instructions_for_compiling.md](firmware/instructions_for_compiling.md).
## Testing
You can see the current tests in [the TESTING.md file](docs/TESTING.md). Note that you need to check some of them yourself, since they're still a work in progress

## Limitations
- Only one 512-bit block at a time.
- Padding is done in software for now
- Can't chain multiple blocks yet
- No PPA analysis yet

