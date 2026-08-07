param(
    [string]$ToolPrefix = $env:RISCV_TOOL_PREFIX
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir = Join-Path $scriptDir "build"

if ($ToolPrefix) {
    $prefixCandidates = @($ToolPrefix)
} else {
    $prefixCandidates = @("riscv64-unknown-elf", "riscv-none-elf")
}

$toolPrefix = $null
foreach ($candidate in $prefixCandidates) {
    if (Get-Command "$candidate-g++" -ErrorAction SilentlyContinue) {
        $toolPrefix = $candidate
        break
    }
}

if (-not $toolPrefix) {
    throw "RISC-V compiler not found. Install a toolchain, add its bin directory to PATH, or set RISCV_TOOL_PREFIX. Read the RV32I_BUILD.md file for help on how to do that."
}

$cxx = "$toolPrefix-g++"
$nmTool = "$toolPrefix-nm"
$sizeTool = "$toolPrefix-size"

foreach ($tool in @($cxx, $nmTool, $sizeTool)) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Required tool not found: $tool"
    }
}

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$commonFlags = @(
    "-std=c++11"
    "-O2"
    "-Wall"
    "-Wextra"
    "-Werror"
    "-march=rv32i"
    "-mabi=ilp32"
    "-DSHA256_NO_STD_STRING"
    "-ffreestanding"
    "-fno-exceptions"
    "-fno-rtti"
    "-fno-threadsafe-statics"
    "-fno-stack-protector"
)

$sourceFile = Join-Path $scriptDir "sha256.cpp"
$objectFile = Join-Path $buildDir "sha256_rv32i.o"
$assemblyFile = Join-Path $buildDir "sha256_rv32i.s"

& $cxx @commonFlags -c $sourceFile -o $objectFile
if ($LASTEXITCODE -ne 0) { throw "Object compilation failed with exit code $LASTEXITCODE." }

& $cxx @commonFlags -S $sourceFile -o $assemblyFile
if ($LASTEXITCODE -ne 0) { throw "Assembly generation failed with exit code $LASTEXITCODE." }

$undefinedSymbols = & $nmTool -C -u $objectFile
if ($LASTEXITCODE -ne 0) { throw "Symbol check failed with exit code $LASTEXITCODE." }
if ($undefinedSymbols) {
    Write-Error "Unresolved symbols found:`n$($undefinedSymbols -join "`n")"
}

Write-Host "RV32I SHA-256 build PASSED with no unresolved symbols. Thank you, bye!"
& $sizeTool $objectFile
if ($LASTEXITCODE -ne 0) { throw "Size reporting failed with exit code $LASTEXITCODE." }
Write-Host "Object:   $objectFile"
Write-Host "Assembly: $assemblyFile"
