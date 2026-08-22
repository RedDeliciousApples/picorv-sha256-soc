# Purpose
Tests that were written as the project progressed, to check that the SoC works correctly end to end.

# Current testbenches

| Testbench | Design under test | Tests performed | Checking method |
|---|---|---|---|
| `sha256_scheduler_tb.sv` | SHA scheduler | Checks all 64 words of the empty-string schedule | Self-checking |
| `sha256_top_tb.sv` | SHA block top | Empty string, `"abc"`, and the 55-byte one-block boundary | Self-checking |
| `axi_tb.sv` | AXI decoder and RAM | Routing, WSTRB, write ordering | Self-checking |
| `sha256-core-tb.sv` | SHA compression core | Empty-string digest and completion timeout | Self-checking |
| `picorv_sha_soc_tb.sv` | Runs firmware, checks empty string result written to RAM | - |Self-checking |
| `picorv_software_sha_tb.sv` | PicoRV32 SoC running software SHA-256 firmware | Empty-string digest and cycle count | Self-checking |
| `basic_comms_test.sv` | SHA register interface | Block-register writes and readback | Self-checking |

All seven testbenches are self-checking.

# Performance measurements

`sha256_block_top_b2b_tb`, `picorv_sha_soc_tb`, and `picorv_software_sha_tb`
emit cycle counts using lines that begin with `MEASURE`. Run all three from the
repository root with:

```text
vivado -mode batch -source tools/run_measurements.tcl -tclargs path/to/picorv.xpr
```

See [PERFORMANCE.md](PERFORMANCE.md) for the current baseline and measurement
details.

# Vivado project setup

Vivado project files are generated locally, they're not tracked by Git. Create a Basys3 project from the repository root with:

```text
vivado -mode batch -source tools/create_vivado_project.tcl
```

This creates `vivado/picorv.xpr`. To relink an existing project after pulling changes:

```text
vivado -mode batch -source tools/relink_vivado_project.tcl \
  -tclargs path/to/picorv.xpr
```

# Running tests

Run the full regression suite with:

```text
vivado -mode batch -source tools/run_regression.tcl \
  -tclargs path/to/picorv.xpr
```

# Known possible regressions

1. SHA register writes may become visible too late. This is hopefully addressed by the `picorv_sha_soc_tb.sv` test.
2. There might be duplicate writes when the decoder handles the address and data channels separately, hopefully also covered by the `picorv_sha_soc_tb.sv` test.

None of these are issues right now, but they might come back if the code changes, so keep that in mind. 
