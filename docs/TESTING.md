# Purpose
Tests that were written as the project progressed, to check that the SoC works correctly end to end.

# Current testbenches

| Testbench | Design under test | Tests performed | Checking method |
|---|---|---|---|
| `sha256_scheduler_tb.sv` | SHA scheduler | Generates 64 schedule words | Visual inspection |
| `sha256_top_tb.sv` | SHA block top | Empty string and `"abc"` | Self-checking |
| `axi_tb.sv` | AXI decoder and RAM | Routing, WSTRB, write ordering | `$error` comparisons |
| `sha256-core-tb.sv` | Core gets empty string and SHA constants, then displays H0–H7 | - | Visual inspection | 
| `picorv_sha_soc_tb.sv` | Runs firmware, checks empty string result written to RAM | - |Self-checking |
| `basic_comms_test.sv` | Tests R/W for SHA registers at offsets 0x08 and 0x0C | - |Visual inspection |

All tests pass as of 7/28/2026
# Known possible regressions

1. SHA register writes may become visible too late. This is hopefully addressed by the `picorv_sha_soc_tb.sv` test.
2. There might be duplicate writes when the decoder handles the address and data channels separately, hopefully also covered by the `picorv_sha_soc_tb.sv` test.

None of these are issues right now, but they might come back if the code changes, so keep that in mind. 
