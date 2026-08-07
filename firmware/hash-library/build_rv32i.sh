#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="${script_dir}/build"

cxx="${CXX:-riscv64-unknown-elf-g++}"
nm_tool="${NM:-riscv64-unknown-elf-nm}"
size_tool="${SIZE:-riscv64-unknown-elf-size}"

for tool in "${cxx}" "${nm_tool}" "${size_tool}"; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "error: required tool not found: ${tool}" >&2
    exit 1
  fi
done

mkdir -p "${build_dir}"

common_flags=(
  -std=c++11
  -O2
  -Wall
  -Wextra
  -Werror
  -march=rv32i
  -mabi=ilp32
  -DSHA256_NO_STD_STRING
  -ffreestanding
  -fno-exceptions
  -fno-rtti
  -fno-threadsafe-statics
  -fno-stack-protector
)

object_file="${build_dir}/sha256_rv32i.o"
assembly_file="${build_dir}/sha256_rv32i.s"

"${cxx}" "${common_flags[@]}" -c "${script_dir}/sha256.cpp" -o "${object_file}"
"${cxx}" "${common_flags[@]}" -S "${script_dir}/sha256.cpp" -o "${assembly_file}"

undefined_symbols="$("${nm_tool}" -C -u "${object_file}")"
if [[ -n "${undefined_symbols}" ]]; then
  echo "error: unresolved symbols found:" >&2
  echo "${undefined_symbols}" >&2
  exit 1
fi

echo "RV32I SHA-256 build PASSED with no unresolved symbols. Thank you, bye!"
"${size_tool}" "${object_file}"
echo "Object:   ${object_file}"
echo "Assembly: ${assembly_file}"
