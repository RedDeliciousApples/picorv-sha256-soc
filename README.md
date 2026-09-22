# PicoRV32 SHA-256 SoC

## Overview
This is a PicoRV32-based RV32I SoC with a memory-mapped SHA-256 peripheral, using the AXI-4 Lite interface, mainly made to help me learn AXI. It can process one 512-bit padded message block per operation.



## ASIC implementation result

The AXI-Lite SHA-256 peripheral succesfully completed a 50 MHz OpenLane
implementation run, and met timing, using the SKY130A `sky130_fd_sc_hd` library.
It uses a 600 x 600 µm die with a 580 x 580 µm core.

| Check | Result |
|---|---:|
| Worst setup slack | +3.025 ns |
| Worst hold slack | +0.043 ns |
| Setup / hold violations | 0 / 0 |
| Max slew / capacitance violations | 0 / 0 |
| Routing, Magic, and KLayout DRC | Clean |
| LVS | Clean |

Notes and reproduction commands are in [asic/openlane_axi_lite](asic/openlane_axi_lite/README.md).

## Tapeout attempts
The first OpenLane attempt is documented in
[asic/openlane](asic/openlane/README.md). It was unsuccessful due to too many I/O ports.

The second attempt is in [asic/openlane_axi_lite](asic/openlane_axi_lite/README.md).

## Performance Result

In self-checking Vivado RTL simulation, hashing an empty message took:

| PicoRV32 path | End-to-end cycles | Time at an assumed 100 MHz |
|---|---:|---:|
| RV32I software SHA-256 | 30,169 | 301.69 us |
| AXI-Lite SHA-256 accelerator | 732 | 7.32 us |

That's a **41.21x speedup**, or **97.57% fewer cycles**, for the
SHA256 accelerator on this PicoRV32 SoC.

This is a comparison of cycle count in simulation. It does NOT mean
Vivado simulation can compute SHA hashes faster than a desktop CPU,
and it is not a physical-board benchmark. A  Vivado 2025.2
implementation meets 100 MHz with +0.522 ns setup
WNS and +0.020 ns hold WHS. Also, the accelerator gets an already padded
block, but the software library does its own padding. See [methodology and
results](docs/PERFORMANCE.md) and the [post-route
reports](results/fpga/2026-09-21-vivado-2025.2-100mhz/).

## Current Status
Works with a 512-bit block, all tests pass. 

## Top diagram
![Level 1 diagram](docs/images/level1diagram.png)


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
After editing [main.c](firmware/main.c) as needed, run these commands from the
`firmware` directory:
```
cd firmware

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
python ../tools/bin_to_mem.py
cp memory.mem ../sim/mem/memory.mem
```
## Testing
You can see the current tests in [the TESTING.md file](docs/TESTING.md).

Specific performance data can be found in [PERFORMANCE.md](docs/PERFORMANCE.md).

## Limitations
- Only one 512-bit block at a time.
- Padding is done in software for now
- Can't chain multiple blocks yet
- No silicon measurement or tapeout yet



