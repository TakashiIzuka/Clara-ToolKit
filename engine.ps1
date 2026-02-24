$path = Join-Path $pwd 'OpenHardwareMonitorLib.dll' 
function DrawBar($p){ $d=[math]::Floor($p*15/100); return "["+("#"*$d)+("-"*(15-$d))+"]" } 
Unblock-File $path -ErrorAction SilentlyContinue 
[System.Reflection.Assembly]::LoadFrom($path) | Out-Null 
$pc = New-Object OpenHardwareMonitor.Hardware.Computer; $pc.CPUEnabled = $true; $pc.Open() 
$cpu = $pc.Hardware | Where-Object {$_.HardwareType -eq 'CPU'}; $cpu.Update() 
$s = $cpu.Sensors | Where-Object {$_.SensorType -eq 'Temperature' -and $_.Name -match 'Package'} | Select-Object -First 1 
$os = Get-CimInstance Win32_OperatingSystem 
$tRam = $os.TotalVisibleMemorySize; $uRamG = [math]::Round(($tRam-$os.FreePhysicalMemory)/1MB, 1); $tRamG = [math]::Round($tRam/1MB, 0); $pRam = ($uRamG/$tRamG)*100 
$dr = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'} 
$fSSD = [math]::Round($dr.FreeSpace/1GB, 1); $tSSD = [math]::Round($dr.Size/1GB, 0); $pSSD = (($tSSD-$fSSD)/$tSSD)*100 
Write-Host '   [ MONITORING KESEHATAN REAL-TIME ]' -ForegroundColor Gray 
Write-Host '   -----------------------------------------------------------------------------------------' -ForegroundColor Gray 
if($s){ $v=$s.Value; $msg = '   SUHU CPU CORE : ' + $v + ' C'; if($v -gt 85){Write-Host $msg ' (DANGER)' -ForegroundColor Red}else{Write-Host $msg ' (NORMAL)' -ForegroundColor Green} } 
Write-Host "   PENGGUNAAN RAM: $(DrawBar $pRam) $uRamG / $tRamG GB" -ForegroundColor Cyan 
Write-Host "   PENGGUNAAN SSD: $(DrawBar $pSSD) Sisa $fSSD / $tSSD GB" -ForegroundColor Cyan 
$pc.Close() 
