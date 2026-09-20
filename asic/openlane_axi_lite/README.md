# OpenLane AXI-Lite SHA-256 peripheral bring-up

This is my second attempt at an OpenLane target for the SHA-256 peripheral. It
tries to compile `sha256_axi_lite`, the AXI to register-interface module, instead of the register-interface module alone.

## Why this target

The `sha256_block_top` config had 774 ports. That created a lot of I/O pressure which caused Place and Route to fail, disastrously. We're trying to expose just the AXI interface this time.

## Initial floorplan

Currently: 600 x 600 µm die, 580 x 580 µm core. My first attempt was
250 x 250 µm which had 268% utilization, so I increased the area. Area may still be changed later.

## Run

From the repo root inside the OpenLane Nix shell (run it with `nix-shell`):

```text
openlane --pdk-root "$HOME/.volare" asic/openlane_axi_lite/config.json
```

