Awesome — you’re at the firmware step now. Since you have the `riscv32-unknown-elf` toolchain, the flow is:

```text
C file -> ELF -> raw binary -> memory.mem
```

Your RAM uses `$readmemh("memory.mem", memory, 0, MEM_WORDS-1);`, so we need a hex file where each line is one 32-bit instruction/data word.

## 1. Create a tiny C program

Make a file called `main.c`:

```c
volatile unsigned int *ram_test = (volatile unsigned int *)0x00000100;

void main(void)
{
    *ram_test = 0x12345678;

    while (1) {
    }
}
```

This program just writes `0x12345678` to RAM address `0x100`.

## 2. Create a linker script

Make a file called `linker.ld`:

```ld
ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    .text : {
        *(.text.start)
        *(.text*)
        *(.rodata*)
    } > RAM

    .data : {
        *(.data*)
    } > RAM

    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM
}
```

## 3. Create a startup assembly file

Make a file called `start.S`:

```asm
.section .text.start
.global _start

_start:
    la sp, _stack_top
    call main

hang:
    j hang

.section .bss
.space 4

.section .text
_stack_top = 0x00008000
```

This gives PicoRV32 a real reset entry point at address `0x0000_0000`.

## 4. Compile

Run:

```bash
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

If your PicoRV32 has `ENABLE_MUL = 0` and `ENABLE_DIV = 0`, keep the C very simple for now. Avoid multiplication/division until you enable those or provide software routines.

## 5. Convert ELF to raw binary

```bash
riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
```

## 6. Convert binary to `memory.mem`

Use this Python script:

```python
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
```

Save it as `bin_to_mem.py`, then run:

```bash
python bin_to_mem.py
```

Now copy `memory.mem` into the directory Vivado simulation expects, usually the simulation run directory or wherever `$readmemh("memory.mem", ...)` resolves from.

## 7. In the SoC testbench, check RAM address `0x100`

Add this to your `picorv_sha_soc_tb`:

```systemverilog
always @(posedge clk) begin
    if (reset_n && dut.ram.memory[32'h100 >> 2] == 32'h12345678) begin
        $display("[%0t] PASS: CPU wrote RAM test value.", $time);
        $finish;
    end
end
```

If that passes, you’ve proven:

```text
PicoRV32 reset vector works
instruction fetch from RAM works
AXI decoder RAM route works
C program executed
store instruction reached RAM
```

That’s a huge milestone before trying SHA.
