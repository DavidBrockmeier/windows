$DOMAIN = Read-Host "Enter domain name"
$DOMAINShort = $DOMAIN.Replace(".", "")
if ($DOMAINShort.length -gt 4) {
	$DOMAINShort = $DOMAINShort.Substring(0, 4)
}
$DOMAINShort = $DOMAINShort.ToUpper()
$hwInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$hwInfo = $hwInfo.Manufacturer
if ($hwInfo.length -gt 4) {
	$hwInfo = $hwInfo.Substring(0, 4)
}
$hwInfo = $hwInfo.ToUpper()
$getMac = Get-WmiObject Win32_NetworkAdapter -Filter 'NetConnectionStatus=2'
$lastOfMac = $getMac.MACAddress -split ":"
$lastOfMac = "$($lastOfMac[4])$($lastOfMac[5])"
$pcName = "$($DOMAINShort)-$($hwInfo)-$($lastOfMac)"
Add-Computer -NewName $pcName -DomainName $DOMAIN -Credential "Administrator"