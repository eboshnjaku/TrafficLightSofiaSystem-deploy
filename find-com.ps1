# Prints the Nucleo's COM port (e.g. COM5), or nothing if it can't be found.
# Matches the ST-Link Virtual COM Port that the Nucleo exposes over USB.
$d = Get-CimInstance Win32_PnPEntity |
     Where-Object { $_.Name -match 'Virtual COM Port \(COM\d+\)' -and ($_.Name -match 'STM' -or $_.Name -match 'STLink') } |
     Select-Object -First 1
if ($d -and $d.Name -match '\((COM\d+)\)') { $Matches[1] }
