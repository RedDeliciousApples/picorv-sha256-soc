# PicoRV32 SHA-256 SoC

## Overview
This is a PicoRV32-based RV32I SoC with a memory-mapped SHA-256 peripheral, using the AXI-4 Lite interface, mainly made to help me learn AXI. It can process one 512-bit padded message block per operation.

## Performance Result

In Vivado behavioral simulation, hashing the empty message and storing its
verified digest took:

| PicoRV32 path | End-to-end cycles | Time at an assumed 100 MHz |
|---|---:|---:|
| RV32I software SHA-256 | 30,169 | 301.69 us |
| AXI-Lite SHA-256 accelerator | 654 | 6.54 us |

That is a **46.13x speedup**, or **97.83% fewer cycles**, for the
SHA256 accelerator on this PicoRV32 SoC.

This is a comparison of cycle count in simulation. It does NOT mean
Vivado simulation can compute SHA hashes faster than a desktop CPU,
 and 100 MHz is only illustrative until I can find the real frequency with timing analysis.
Also, the accelerator gets an already padded block, but the software library does its own padding. See [methodology and results](docs/PERFORMANCE.md).



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

Cycle-level accelerator and end-to-end baselines are recorded in [PERFORMANCE.md](docs/PERFORMANCE.md).

## Limitations
- Only one 512-bit block at a time.
- Padding is done in software for now
- Can't chain multiple blocks yet
- No PPA analysis yet

