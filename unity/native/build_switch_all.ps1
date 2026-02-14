# Build PuertsCore and PapiQuickjs for Nintendo Switch
# PowerShell version

param(
    [string]$Config = "Release"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Building Puerts for Nintendo Switch" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check Nintendo SDK environment
if (-not $env:NINTENDO_SDK_ROOT) {
    Write-Host "ERROR: NINTENDO_SDK_ROOT environment variable not found" -ForegroundColor Red
    Write-Host "Please install Nintendo Switch SDK and set the environment variable" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Nintendo SDK: $env:NINTENDO_SDK_ROOT" -ForegroundColor Green
Write-Host "Build Configuration: $Config" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

# Check if Ninja is available
$ninjaPath = Get-Command ninja -ErrorAction SilentlyContinue
if (-not $ninjaPath) {
    Write-Host "WARNING: Ninja build system not found in PATH" -ForegroundColor Yellow
    Write-Host "Attempting to use default generator..." -ForegroundColor Yellow
}

# Build PuertsCore
Write-Host ""
Write-Host "Step 1/2: Building PuertsCore..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Push-Location "puerts"
& powershell -ExecutionPolicy Bypass -File "make_switch.ps1" $Config
$puertsCoreResult = $LASTEXITCODE
Pop-Location

if ($puertsCoreResult -ne 0) {
    Write-Host "ERROR: PuertsCore build failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Build PapiQuickjs
Write-Host ""
Write-Host "Step 2/2: Building PapiQuickjs..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Push-Location "papi-quickjs"
& powershell -ExecutionPolicy Bypass -File "make_switch.ps1" $Config
$papiQuickjsResult = $LASTEXITCODE
Pop-Location

if ($papiQuickjsResult -ne 0) {
    Write-Host "ERROR: PapiQuickjs build failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "All builds completed successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output files:" -ForegroundColor White
Write-Host "  PuertsCore:   puerts\lib\libPuertsCore.a" -ForegroundColor White
Write-Host "  PapiQuickjs:  papi-quickjs\build_switch\libPapiQuickjs.a" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Unity Integration Steps:" -ForegroundColor Yellow
Write-Host "1. Copy the .a files to Unity project Plugins/Switch directory"
Write-Host "2. Ensure the libraries are configured for Switch platform in Unity"
Write-Host "3. The libraries will be statically linked when building for Switch"
Write-Host "==========================================" -ForegroundColor Cyan

Read-Host "Press Enter to exit"
