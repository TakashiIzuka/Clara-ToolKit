@echo off
setlocal enabledelayedexpansion

:: --- 1. MANTRA AUTO ADMIN ---
net session >nul 2>&1 || (powershell start -verb runas '"%~0"' & exit /b)
cd /d "%~dp0"

title CLARA'S SUPREME TOOLKIT v1.0 - UNIVERSAL AUTO-DETECT
color 0b

:: --- 2. AMBIL DATA HARDWARE (AUTO-DETECT MODEL) ---
for /f "delims=" %%a in ('powershell -command "(Get-CimInstance Win32_ComputerSystem).Model"') do set "v_model=%%a"
for /f "delims=" %%a in ('powershell -command "(Get-CimInstance Win32_ComputerSystem).Manufacturer"') do set "v_brand=%%a"
for /f "delims=" %%a in ('powershell -command "(Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion"') do set "bios=%%a"
for /f "delims=" %%a in ('powershell -command "(Get-CimInstance Win32_DiskDrive | Select-Object -First 1).Model"') do set "ssd_m=%%a"
for /f "delims=" %%a in ('powershell -command "(Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1).PartNumber"') do set "ram_m=%%a"

:menu
cls
:: Ambil Clock Speed Real-Time
for /f "delims=" %%a in ('powershell -command "[math]::Round((Get-CimInstance Win32_Processor).CurrentClockSpeed / 1000, 2)"') do set "speed=%%a"

echo  ###########################################################################################
echo  #                                                                                         #
echo  #               CLARA'S SUPREME TOOLKIT v1.0 - UNIVERSAL AUTO-DETECT                     #
echo  #                                                                                         #
echo  ###########################################################################################
echo.
echo    [ IDENTITAS PERANGKAT ]
echo    -----------------------------------------------------------------------------------------
echo    Merek/Brand  : %v_brand%
echo    Model Laptop : %v_model%
echo    Versi BIOS   : %bios%
echo    Model RAM    : %ram_m%
echo    Model SSD    : %ssd_m%
echo.

:: --- 3. RAKIT MESIN SENSOR v1.0 (STABIL) ---
echo $path = Join-Path $pwd 'OpenHardwareMonitorLib.dll' > engine.ps1
echo function DrawBar($p){ $d=[math]::Floor($p*15/100); return "["+("#"*$d)+("-"*(15-$d))+"]" } >> engine.ps1
echo Unblock-File $path -ErrorAction SilentlyContinue >> engine.ps1
echo [System.Reflection.Assembly]::LoadFrom($path) ^| Out-Null >> engine.ps1
echo $pc = New-Object OpenHardwareMonitor.Hardware.Computer; $pc.CPUEnabled = $true; $pc.Open() >> engine.ps1
echo $cpu = $pc.Hardware ^| Where-Object {$_.HardwareType -eq 'CPU'}; $cpu.Update() >> engine.ps1
echo $s = $cpu.Sensors ^| Where-Object {$_.SensorType -eq 'Temperature' -and $_.Name -match 'Package'} ^| Select-Object -First 1 >> engine.ps1
echo $os = Get-CimInstance Win32_OperatingSystem >> engine.ps1
echo $tRam = $os.TotalVisibleMemorySize; $uRamG = [math]::Round(($tRam-$os.FreePhysicalMemory)/1MB, 1); $tRamG = [math]::Round($tRam/1MB, 0); $pRam = ($uRamG/$tRamG)*100 >> engine.ps1
echo $dr = Get-CimInstance Win32_LogicalDisk ^| Where-Object {$_.DeviceID -eq 'C:'} >> engine.ps1
echo $fSSD = [math]::Round($dr.FreeSpace/1GB, 1); $tSSD = [math]::Round($dr.Size/1GB, 0); $pSSD = (($tSSD-$fSSD)/$tSSD)*100 >> engine.ps1
echo Write-Host '   [ MONITORING KESEHATAN REAL-TIME ]' -ForegroundColor Gray >> engine.ps1
echo Write-Host '   -----------------------------------------------------------------------------------------' -ForegroundColor Gray >> engine.ps1
echo if($s){ $v=$s.Value; $msg = '   SUHU CPU CORE : ' + $v + ' C'; if($v -gt 85){Write-Host $msg ' (DANGER!)' -ForegroundColor Red}else{Write-Host $msg ' (NORMAL)' -ForegroundColor Green} } >> engine.ps1
echo Write-Host "   PENGGUNAAN RAM: $(DrawBar $pRam) $uRamG / $tRamG GB" -ForegroundColor Cyan >> engine.ps1
echo Write-Host "   PENGGUNAAN SSD: $(DrawBar $pSSD) Sisa $fSSD / $tSSD GB" -ForegroundColor Cyan >> engine.ps1
echo $pc.Close() >> engine.ps1

powershell -NoProfile -ExecutionPolicy Bypass -File "engine.ps1"

echo    Clock Speed  : %speed% GHz (Real-Time Boost)
echo.
echo  ###########################################################################################
echo  #  [1] Refresh Data    [2] SSD Cleaner    [3] Cek Uptime    [X] Keluar		        #
echo  ###########################################################################################
echo.
set /p opt=" > Pilih Menu: "

if "%opt%"=="1" goto menu
if "%opt%"=="2" goto cleaner
if "%opt%"=="3" goto uptime
if /i "%opt%"=="X" ( del engine.ps1 >nul 2>&1 & exit )
goto menu

:cleaner
cls
echo.
echo [CLARA] Sedang menyapu sampah di SSD kamu...
del /f /s /q C:\Windows\Temp\* >nul 2>&1
del /f /s /q %temp%\* >nul 2>&1
echo.
echo [OK] SSD Bersih!
pause
goto menu

:uptime
cls
echo.
echo [CLARA] Menghitung waktu nyala laptop...
powershell -Command "Write-Host 'Laptop kamu sudah nyala selama:' (New-TimeSpan -Start (Get-CimInstance Win32_OperatingSystem).LastBootUpTime -End (Get-Date)).ToString('dd\ \h\a\r\i\,\ hh\ \j\a\m\,\ mm\ \m\e\n\i\t')"
pause

goto menu
