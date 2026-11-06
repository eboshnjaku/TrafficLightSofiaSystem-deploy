# Prints this laptop's IPv4 address on the network that has a router (default gateway) -
# i.e. the address the ESP-01 must use as MQTT_HOST. Skips VMware/virtual adapters (no gateway).
$c = Get-NetIPConfiguration -ErrorAction SilentlyContinue |
     Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
     Select-Object -First 1
if ($c) { $c.IPv4Address.IPAddress | Select-Object -First 1 }
