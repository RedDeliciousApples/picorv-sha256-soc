# PicoRV32 Software SHA-256 Firmware Build
Did you run the important file titled `RUNMEFIRST-sha256-onlyRV32I_BUILD.md` first?
If not, please go do that.
It will be very important, since this file expects you to have run that.

From this directory in WSL or Linux:

```bash
mkdir -p build

riscv64-unknown-elf-g++ \
  -std=c++11 -O2 \
  -Wall -Wextra -Werror -Wno-array-bounds \
  -march=rv32i -mabi=ilp32 \
  -DSHA256_NO_STD_STRING \
  -ffreestanding \
  -fno-exceptions \
  -fno-rtti \
  -fno-threadsafe-statics \
  -fno-stack-protector \
  -ffunction-sections \
  -fdata-sections \
  -nostdlib \
  -nostartfiles \
  -T linker.ld \
  -Wl,--gc-sections \
  -Wl,-Map=build/software_sha.map \
  start.S main.cpp sha256.cpp \
  -o build/software_sha.elf

riscv64-unknown-elf-objcopy \
  -O binary \
  build/software_sha.elf \
  build/firmware.bin

cd build
python3 ../../../tools/bin_to_mem.py
cd ..
```

Check the result. The `nm` command should print nothing:

```bash
riscv64-unknown-elf-size build/software_sha.elf
riscv64-unknown-elf-nm -C -u build/software_sha.elf
```

You now have a `.mem` file! Copy it somewhere conveinient, and you can start using Vivado:

```bash
cp build/memory.mem ../../sim/mem/memory.mem
```

The current `main.cpp` hashes the empty input, matching the digest expected by
`sim/tb/picorv_sha_soc_tb.sv`. 

NOTE TO SELF: Increase that testbench timeout before running
the software implementation, bcuz 5,000 cycles is for the accelerator. software will be slower.

`-Wno-array-bounds` is because GCC doesn't like writes to low RAM addresses like `0x100` and `0x120`. All other enabled warnings remain
errors.
