$ver = "1.0.2"
function Decrypt-String ($Encrypted,$Passphrase,$salt = "Ad3t049866",$init = "Ad3t0PASS")
{
	if ($Encrypted -is [string]) {
		$Encrypted = [Convert]::FromBase64String($Encrypted)
	}
	$r = New-Object System.Security.Cryptography.RijndaelManaged
	$pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
	$salt = [Text.Encoding]::UTF8.GetBytes($salt)
	$r.Key = (New-Object Security.Cryptography.PasswordDeriveBytes $pass,$salt,"SHA1",5).GetBytes(32)
	$r.IV = (New-Object Security.Cryptography.SHA1Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($init))[0..15]
	$d = $r.CreateDecryptor()
	$ms = New-Object IO.MemoryStream @(,$Encrypted)
	$cs = New-Object Security.Cryptography.CryptoStream $ms,$d,"Read"
	$sr = New-Object IO.StreamReader $cs
	Write-Output $sr.ReadToEnd()
	$sr.Close()
	$cs.Close()
	$ms.Close()
	$r.Clear()
}
$encURL = "GkNRDbdvqsKt49ugrqVnMSWWMLeJ9rqzc0nM+tFQyyhzt86vi0Z48AOYbBddxrivJBcdMVe/KXFlCBTZ7rwSYIor7C9Ns4O4XXJt61kxWPamS7R2lZgb4/VTDTWYrRDUN5aSj9XRGgyDPtqaqV0CABOcl22NiFl3+jzy3rT+9yNMFvBC4CYU2Ci2IVpVkJYY"
$checkLicenseStatus = cscript C:\Windows\System32\slmgr.vbs /dli
if ($checkLicenseStatus -like "*Licensed*")
{
	Write-Host "Windows is already licensed exiting..."
}
else
{
	$pass = Read-Host "Password"
	$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
	$keys = Invoke-WebRequest -Uri $decURL -UseBasicParsing
	[string[]]$lkArray = $keys.Content
	$lkAttempt = 0
	while ($checkLicenseStatus -like "*Notification*" -and $lkAttempt -le $lkArray.Count)
	{
		Write-Host "Windows Is Not Licensed"
		cscript C:\Windows\System32\slmgr.vbs /ipk $lkArray[$lkAttempt]
		Sleep 2
		cscript C:\Windows\System32\slmgr.vbs /ato
		Sleep 2
		$lkAttempt = $lkAttempt += 1
		$checkLicenseStatus = cscript C:\Windows\System32\slmgr.vbs /dli
	}
	if ($checkLicenseStatus -like "*Licensed*")
	{
		Write-Host "Windows was licensed successfully!"
	}
	else
	{
		Write-Host "Windows licensing failed"
	}
}
