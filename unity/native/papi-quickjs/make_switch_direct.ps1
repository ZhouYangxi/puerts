# PapiQuickjs for Nintendo Switch - Direct Build Script (No CMake Required)
# PowerShell version

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "PapiQuickjs for Nintendo Switch" -ForegroundColor Cyan
Write-Host "Direct Compilation (No CMake)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check Nintendo SDK environment
if (-not $env:NINTENDO_SDK_ROOT) {
    Write-Host "ERROR: NINTENDO_SDK_ROOT environment variable not found" -ForegroundColor Red
    Write-Host "Please install Nintendo Switch SDK and set the environment variable" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Nintendo SDK: $env:NINTENDO_SDK_ROOT" -ForegroundColor Green

# Set compiler paths
$COMPILER_ROOT = Join-Path $env:NINTENDO_SDK_ROOT "Compilers\NintendoClang\bin"
$CC = Join-Path $COMPILER_ROOT "clang.exe"
$CXX = Join-Path $COMPILER_ROOT "clang++.exe"
$AR = Join-Path $COMPILER_ROOT "llvm-ar.exe"

if (-not (Test-Path $CC)) {
    Write-Host "ERROR: Compiler not found at $CC" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Compiler: $CC" -ForegroundColor Green

# Check if PuertsCore is built
$PUERTS_LIB = "..\puerts\lib\libPuertsCore.a"
if (-not (Test-Path $PUERTS_LIB)) {
    Write-Host "ERROR: PuertsCore library not found at $PUERTS_LIB" -ForegroundColor Red
    Write-Host "Please build PuertsCore first by running:" -ForegroundColor Yellow
    Write-Host "  cd ..\puerts" -ForegroundColor Yellow
    Write-Host "  .\make_switch_direct.ps1" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "PuertsCore library found" -ForegroundColor Green

# Build configuration
$CONFIG = if ($args.Count -gt 0) { $args[0] } else { "Release" }
Write-Host "Build Configuration: $CONFIG" -ForegroundColor Green

# Compilation flags
$TARGET = "--target=aarch64-nintendo-nx-elf"
$COMMON_FLAGS = @(
    $TARGET,
    "-march=armv8-a",
    "-mtune=cortex-a57",
    "-fPIC",
    "-D__SWITCH__",
    "-D_CHAR16T",
    "-D_CRT_SECURE_NO_WARNINGS",
    "-D_SCL_SECURE_NO_WARNINGS",
    "-DEASTL_OPENSOURCE=1",
    "-D_GNU_SOURCE",
    "-DEA_DEPRECATIONS_FOR_2024_APRIL=EA_DISABLED",
    "-DEA_DEPRECATIONS_FOR_2024_SEPT=EA_DISABLED",
    "-DEA_DEPRECATIONS_FOR_2025_APRIL=EA_DISABLED",
    "-DEASTL_DLL",
    "-DUSING_EASTL",
    "-DUSING_REGISTER_API_SHARED",
    "-DEA_PLATFORM_POSIX=1",
    "-DEA_PROCESSOR_ARM64=1",
    "-DEA_SYSTEM_LITTLE_ENDIAN=1",
    "-Iinclude",
    "-Iquickjs",
    "-I..\EASTL\include",
    "-I..\puerts\include",
    "-I`"$env:NINTENDO_SDK_ROOT\Include`""
)

$C_FLAGS = $COMMON_FLAGS + @(
    "-std=c11",
    "-funsigned-char",
    "-Wno-implicit-fallthrough",
    "-Wno-sign-compare",
    "-Wno-missing-field-initializers",
    "-Wno-unused-parameter",
    "-Wno-unused-variable",
    "-fno-strict-aliasing"
)

$CXX_FLAGS = $COMMON_FLAGS + @(
    "-std=c++14",
    "-fno-exceptions",
    "-fno-unwind-tables",
    "-fno-asynchronous-unwind-tables",
    "-fno-rtti"
)

if ($CONFIG -eq "Release") {
    $C_FLAGS += @("-O2", "-DNDEBUG", "-ffunction-sections", "-fdata-sections")
    $CXX_FLAGS += @("-O2", "-DNDEBUG", "-ffunction-sections", "-fdata-sections")
} else {
    $C_FLAGS += @("-g", "-O0")
    $CXX_FLAGS += @("-g", "-O0")
}

# Output directory
$OUTPUT_DIR = "build_switch"
if (Test-Path $OUTPUT_DIR) {
    Write-Host "Cleaning old build directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $OUTPUT_DIR
}
New-Item -ItemType Directory -Path $OUTPUT_DIR | Out-Null

# Source files
$QJS_C_SOURCES = @(
    "quickjs\cutils.c",
    "quickjs\libbf.c",
    "quickjs\libregexp.c",
    "quickjs\libunicode.c",
    "quickjs\quickjs.c"
)

$PAPI_CPP_SOURCES = @(
    "source\PapiQuickjsImpl.cpp",
    "source\CppObjectMapperQuickjs.cpp",
    "source\BackendEnv.cpp",
    "source\PapiExport.cpp"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Compiling QuickJS source files..." -ForegroundColor Yellow

$OBJ_FILES = @()

# Compile QuickJS C sources
foreach ($source in $QJS_C_SOURCES) {
    $basename = [System.IO.Path]::GetFileNameWithoutExtension($source)
    $objFile = Join-Path $OUTPUT_DIR "qjs_$basename.o"
    Write-Host "  $source" -ForegroundColor White

    & $CC $C_FLAGS -c $source -o $objFile

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Compilation failed for $source" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    $OBJ_FILES += $objFile
}

Write-Host "Compiling PAPI source files..." -ForegroundColor Yellow

# Compile PAPI C++ sources
foreach ($source in $PAPI_CPP_SOURCES) {
    $basename = [System.IO.Path]::GetFileNameWithoutExtension($source)
    $objFile = Join-Path $OUTPUT_DIR "papi_$basename.o"
    Write-Host "  $source" -ForegroundColor White

    & $CXX $CXX_FLAGS -c $source -o $objFile

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Compilation failed for $source" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    $OBJ_FILES += $objFile
}

# Create static library
Write-Host "Creating static library..." -ForegroundColor Yellow
$libFile = Join-Path $OUTPUT_DIR "libPapiQuickjs.a"
& $AR rcs $libFile $OBJ_FILES

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create static library" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Static library: $libFile" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: When linking in Unity, you need both:" -ForegroundColor Yellow
Write-Host "  - $libFile" -ForegroundColor White
Write-Host "  - $PUERTS_LIB" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan

Read-Host "Press Enter to exit"
