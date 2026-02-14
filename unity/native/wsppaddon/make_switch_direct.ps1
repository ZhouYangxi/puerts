# WSPPAddon for Nintendo Switch - Direct Build Script (No CMake Required)
# PowerShell version

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "WSPPAddon for Nintendo Switch" -ForegroundColor Cyan
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

Write-Host "Compiler: $CXX" -ForegroundColor Green

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
    "-DASIO_NO_TYPEID",
    "-DASIO_STANDALONE",
    "-D_WEBSOCKETPP_CPP11_TYPE_TRAITS_",
    "-D_POSIX_C_SOURCE=200809L",
    "-I..\..\..\unreal\Puerts\ThirdParty\Include\websocketpp",
    "-I..\..\..\unreal\Puerts\ThirdParty\Include\asio",
    "-I..\puerts\include",
    "-I`"$env:NINTENDO_SDK_ROOT\Include`""
)

$CXX_FLAGS = $COMMON_FLAGS + @(
    "-std=c++14"
    # Note: WSPPAddon requires exceptions, so we don't disable them
    # "-fno-exceptions",
    # "-fno-unwind-tables",
    # "-fno-asynchronous-unwind-tables",
    # "-fno-rtti"
)

if ($CONFIG -eq "Release") {
    $CXX_FLAGS += @("-O2", "-DNDEBUG", "-ffunction-sections", "-fdata-sections")
} else {
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
$CPP_SOURCES = @(
    "source\WSPPAddon.cpp"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Compiling source files..." -ForegroundColor Yellow

$OBJ_FILES = @()

# Compile C++ sources
foreach ($source in $CPP_SOURCES) {
    $basename = [System.IO.Path]::GetFileNameWithoutExtension($source)
    $objFile = Join-Path $OUTPUT_DIR "$basename.o"
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
$LIB_DIR = "lib"
if (-not (Test-Path $LIB_DIR)) {
    New-Item -ItemType Directory -Path $LIB_DIR | Out-Null
}

$libFile = Join-Path $LIB_DIR "libWSPPAddon.a"
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

Read-Host "Press Enter to exit"
