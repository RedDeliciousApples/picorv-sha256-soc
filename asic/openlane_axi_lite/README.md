# OpenLane AXI-Lite SHA-256 peripheral bring-up

This is my second attempt at an OpenLane target for the SHA-256 peripheral. It
tries to compile `sha256_axi_lite`, the AXI to register-interface module, instead of the register-interface module alone.

## Why this target

The `sha256_block_top` config had 774 ports. That created a lot of I/O pressure which caused Place and Route to fail, disastrously. We're trying to expose just the AXI interface this time.

## Timing history
| Run / change | Setup WNS | Hold WNS | Setup violations | Max slew | Max cap |
|---|---:|---:|---:|---:|---:|
| Initial explicit-SDC 50 MHz run | −2.238 ns | +0.027 ns | 174 | 934 | 27 |
| Scheduler shift-register rewrite | +3.252 ns | +0.055 ns | 0 | 168 | 7 |
| Slow-corner + post-route repair | +3.099 ns | +0.042 ns | 0 | 151 | 9 |
| Final run with max wire length | +3.025 ns | +0.043 ns | 0 | 0 | 0 |

## Initial floorplan

Currently: 600 x 600 µm die, 580 x 580 µm core. My first attempt was
250 x 250 µm which had 268% utilization, so I increased the area. Area may still be changed later.

## SDC files
After that failed, I decided to add explicit `pnr.sdc` and `signoff.sdc` files. Those used a 20 ns clock period, 4ns input/output delays, and various other small options. More specifically:

* 50 MHz / 20 ns clock
* 4 ns AXI input and output delays
* 0.250 ns clock uncertainty
* 0.150 ns transition assumption
* 5% early/late derates

## Reset synchronizer
Next, I added a reset synchronizer so that the AXI interface would correctly wait 2 or 3 clock cycles before resetting instead of doing it instantly (or, "synchronizes reset deassertion over two clock cycles", as an engineer would say). The design was coutesy of https://fpgacpu.ca/fpga/Reset_Synchronizer.html. Although that helped timing by a tiny bit, it still wasn't enough.

## Timing

Investigating the timing further led me to find that round_count was the worst path - it was responsible for most of the worst negative slack and had a fanout of 44. I fixed that by changing the circular buffer, `w_mem[round[3:0]] <= w_new;`, to a for loop. After that, RTL tests were all good, and timing was closed too, at 50 MHz.

## Slew violations

There were still about 160 slew violations and 9 max cap violations in the final design. I tried editing the config.json to target the worst corner: 

```
  "DEFAULT_CORNER": "max_ss_100C_1v60",
  "DESIGN_REPAIR_MAX_SLEW_PCT": 30,
  "DESIGN_REPAIR_MAX_CAP_PCT": 30,
  "RUN_POST_GRT_DESIGN_REPAIR": true,
  ```
  But that only reduced the amount of slew violations by about 10. The thing that finally worked was setting my max wire length to 300 micrometers (1/2 my length/width):
  
  `"DESIGN_REPAIR_MAX_WIRE_LENGTH": 300`

  and the design was ready for signoff after that.

## Run

From the repo root inside the OpenLane Nix shell (run it with `nix-shell`):

```text
openlane --pdk-root "$HOME/.volare" asic/openlane_axi_lite/config.json
```

