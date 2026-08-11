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

You now have a `.mem` file! Copy it into the software testbench's memory file:

```bash
cp build/memory.mem ../../sim/mem/software_sha.mem
```

The current `main.cpp` hashes the empty input, matching the digest expected by
`sim/tb/picorv_software_sha_tb.sv`. The accelerator testbench continues to use
`sim/mem/memory.mem`.

`-Wno-array-bounds` is because GCC doesn't like writes to fixed bare-metal RAM
addresses. All other enabled warnings remain errors.
