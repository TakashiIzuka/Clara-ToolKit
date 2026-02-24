$dll = [IO.Path]::Combine('C:\Users\Izuka\Desktop\.', 'OpenHardwareMonitorLib.dll') 
Unblock-File $dll -ErrorAction SilentlyContinue 
[System.Reflection.Assembly]::LoadFrom($dll) | Out-Null 
$pc = New-Object OpenHardwareMonitor.Hardware.Computer; $pc.CPUEnabled = $true; $pc.Open() 
$cpu = $pc.Hardware | Where-Object {$_.HardwareType -eq 'CPU'}; $cpu.Update() 
$s = $cpu.Sensors | Where-Object {$_.SensorType -eq 'Temperature' -and ($_.Name -like '*Package*' -or $_.Name -like '*Core*')} | Select-Object -First 1 
$os = Get-CimInstance Win32_OperatingSystem 
$totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 0) 
$usedRam = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1) 
$drive = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'} 
$freeSSD = [math]::Round($drive.FreeSpace / 1GB, 1) 
$totalSSD = [math]::Round($drive.Size / 1GB, 0) 
if($s){ 
   $v = [math]::Round($s.Value, 2) 
   if($v -gt 80){ Write-Host "    SUHU CPU CORE : $v C (BAHAYA)" -ForegroundColor Red } 
   else { Write-Host "    SUHU CPU CORE : $v C (AKURAT)" -ForegroundColor Green } 
} 
Write-Host "    PENGGUNAAN RAM: $usedRam GB / $totalRam GB" -ForegroundColor Cyan 
Write-Host "    SISA SSD (C:) : $freeSSD GB / $totalSSD GB" -ForegroundColor Cyan 
$pc.Close() 
