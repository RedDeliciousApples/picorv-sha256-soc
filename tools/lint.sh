#!/usr/bin/env bash
# Lint the RTL with Verilator
#If you don't have Verilator, install with "sudo apt install verilator" on Ubuntu
set -u
cd "$(dirname "$0")/.."

SHA_FILES="rtl/sha256/sha256_core.sv rtl/sha256/sha256_scheduler.sv
           rtl/sha256/sha256_top.sv rtl/sha256/sha256_reg_if.sv
           rtl/sha256/sha256_axi_lite.sv"
SOC_FILES="rtl/bus/axi_lite_ram.sv rtl/bus/axi_lite_2peripheral_decoder.sv
           $SHA_FILES rtl/soc/picorv_sha_soc.sv"

# picorv32.v warnings are waived in lint_waivers.vlt
THIRD_PARTY="rtl/third_party/picorv32.v"
WAIVERS="tools/lint_waivers.vlt"

status=0
verilator --version

echo "=== sha256_axi_lite ==="
verilator --lint-only -Wall --top-module sha256_axi_lite \
    $WAIVERS $SHA_FILES || status=1

echo "=== picorv_sha_soc ==="
verilator --lint-only -Wall --top-module picorv_sha_soc \
    $WAIVERS $THIRD_PARTY $SOC_FILES || status=1

exit $status
