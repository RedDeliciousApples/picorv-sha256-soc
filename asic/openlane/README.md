# OpenLane SHA-256 accelerator bring-up

This first OpenLane run was meant to help me explore how OpenLane works. It had something like 5000 shorts and numerous other PnR errors, probably because I was building the register interface which had 774 I/O pins. I decided to abandon this attempt and move on to the attempt in openlane_axi_lite.

## Target

| Setting | Value | Reason |
|---|---|---|
| PDK | `sky130A` | Widely used, apparently a good starter PDK |
| Standard-cell library | `sky130_fd_sc_hd` | Standard digital-cell library for the PDK |
| Top | `sha256_block_top` | The accelerator only |
| Initial clock period | 20 ns (50 MHz) | Just to explore, 100MHz may work as well |
| Die/core outline | 700 x 700 / 680 x 680 µm | For the 774-bit wide interface |

