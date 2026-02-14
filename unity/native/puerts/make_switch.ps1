# PuertsCore for Nintendo Switch - Build Script
# PowerShell version

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "PuertsCore for Nintendo Switch" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check Nintendo SDK environment
if (-not $env:NINTENDO_SDK_ROOT) {
    Write-Host "ERROR: NINTENDO_SDK_ROOT environment variable not found" -ForegroundColor Red
    Write-Host "Please install Nintendo Switch SDK and set the environment variable" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Nintendo SDK: $env:NINTENDO_SDK_ROOT" -ForegroundColor Green

# Set build configuration
$CONFIG = if ($args.Count -gt 0) { $args[0] } else { "Release" }
Write-Host "Build Configuration: $CONFIG" -ForegroundColor Green

# Build directory
$BUILD_DIR = "build_switch"
if (Test-Path $BUILD_DIR) {
    Write-Host "Cleaning old build directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $BUILD_DIR
}

New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
Write-Host "Build directory: $BUILD_DIR" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

# Configure with CMake
Write-Host "Configuring CMake..." -ForegroundColor Yellow
Push-Location $BUILD_DIR

$TOOLCHAIN_FILE = "..\cmake\switch.toolchain.cmake"
$cmakeArgs = @(
    "-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE",
    "-DCMAKE_BUILD_TYPE=$CONFIG",
    "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON",
    "-G", "Ninja",
    ".."
)

& cmake $cmakeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed" -ForegroundColor Red
    Pop-Location
    Read-Host "Press Enter to exit"
    exit 1
}

# Build
Write-Host "Building PuertsCore..." -ForegroundColor Yellow
& cmake --build . --config $CONFIG

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed" -ForegroundColor Red
    Pop-Location
    Read-Host "Press Enter to exit"
    exit 1
}

# Install
Write-Host "Installing..." -ForegroundColor Yellow
& cmake --build . --target install --config $CONFIG

Pop-Location

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Static library: lib\libPuertsCore.a" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan

Read-Host "Press Enter to exit"
