# Performance Measurements

Cycle counts are the primary metric. Testbench time assumes the current 10 ns
clock period, but it is not a measured FPGA maximum clock frequency.

## Baseline

Measured with Vivado 2025.2 behavioral simulation on August 4, 2026.

| Measurement | Cycles | Time at 100 MHz |
|---|---:|---:|
| SHA block latency, empty string | 67 | 670 ns |
| SHA block latency, `abc` | 67 | 670 ns |
| Reset release to first block write | 55 | 550 ns |
| First block write through start command | 288 | 2.88 us |
| Start command to accelerator busy | 1 | 10 ns |
| Accelerator busy through done | 67 | 670 ns |
| Accelerator done through final digest store | 243 | 2.43 us |
| First block write through final digest store | 599 | 5.99 us |
| Reset release through final digest store | 654 | 6.54 us |

The raw accelerator accounts for 67 of the 654 end-to-end cycles. This baseline
does not yet include multi-block hashing, synthesis resource usage, or
post-implementation timing.

## Software Baseline

Measured with Vivado 2025.2 behavioral simulation on August 10, 2026. The
firmware uses the string-free C++ SHA-256 implementation, which you can read
more about in [the firmware directory](../firmware/hash-library/).

| Measurement | Cycles | Time at 100 MHz |
|---|---:|---:|
| Reset release to software start marker | 61 | 610 ns |
| Software SHA setup through digest store | 30,108 | 301.08 us |
| Reset release through completion marker | 30,169 | 301.69 us |

The empty-string digest was checked in RAM before the test passed.

## Defining "Speedup"

An easy way to compare is by using cycle count for the same result:
reset is released, the empty message is hashed, and the verified digest is
stored in RAM.

```text
end-to-end speedup = software.total_cycles / soc.total_cycles
```

For the current measurements:

```text
end-to-end speedup = 30,169 / 654 = 46.13x
end-to-end cycle reduction = 1 - (654 / 30,169) = 97.83%
```

Both testbenches use the same PicoRV32, AXI RAM, clock, reset sequence, digest,
and simulator. The software testbench also reports:

- `software.reset_to_start_cycles`: firmware startup before the benchmark marker
- `software.hash_and_store_cycles`: SHA setup, padding, compression, and digest store

The closest current operation-level comparison is:

```text
operation speedup = software.hash_and_store_cycles / soc.operation_cycles
```

For the current measurements:

```text
operation speedup = 30,108 / 599 = 50.26x
operation cycle reduction = 1 - (599 / 30,108) = 98.01%
```

This operation comparison is not perfectly equivalent: the
accelerator firmware writes a padded 512-bit block, but
the software library accepts the empty byte string and performs padding itself.

## Findings

What we (royal we) found is that for this specific PicoRV32 core, specifically the AXI variant, can run SHA-256 operations about 46 times faster
when the algorithm is baked into the hardware. In other words, for this core, and only this core, we made SHA-256 faster.

This does NOT mean:
- You can run SHA-256 faster than current modern CPUs. Much smarter people than me have worked on optimizing that as much as possible. What I did was optimize it specifically on the PicoRV32 software CPU.
- A hypothetical fabbed version of this design would achieve a 46x speedup. While it would still be faster, there's plenty of factors to consider that may make it slower than simulation.
- This is the best result we can get. We could still experiment with parallel processing, multiple cores, pipelining, or many other things.
- The design will run at 100MHz. It's unlikely to, and I haven't run any timing analysis yet.

## Running The Measurements

The block-level, accelerator SoC, and software SoC testbenches emit
machine-readable lines beginning with `MEASURE`. You can run all three with:

```text
vivado -mode batch -source tools/run_measurements.tcl \
  -tclargs path/to/picorv.xpr
```

The runner restores `picorv_sha_soc_tb` as the simulation top before exiting.
