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
does not yet include a software SHA-256 implementation, multi-block hashing,
synthesis resource usage, or post-implementation timing.

## Running The Measurements

The block-level and SoC testbenches emit machine-readable lines beginning with
`MEASURE`. Run both through the linked Vivado project with:

```text
vivado -mode batch -source tools/run_measurements.tcl \
  -tclargs path/to/picorv.xpr
```

The runner restores `picorv_sha_soc_tb` as the simulation top before exiting.
