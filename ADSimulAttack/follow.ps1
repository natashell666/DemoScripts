$downloadUrl = "https://github.com/n0dec/MalwLess/releases/download/latest/malwless.zip"
$outputPath = "C:\demo\malwless.zip"
$extra1 = "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/mimikatz.json"
$extra2 = "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/active-guest-acccount-admin.json"
$extra3 = "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/js-dropper.json"
$extra4 = "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/wmi-backdoor-c2.json"
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

$extractPath = "C:\demo\Malware"
Expand-Archive -Path $outputPath -DestinationPath $extractPath
Set-Location -Path $extractPath

Invoke-WebRequest -Uri $extra1 -OutFile $extractPath\1.json
Invoke-WebRequest -Uri $extra2 -OutFile $extractPath\2.json
Invoke-WebRequest -Uri $extra3 -OutFile $extractPath\3.json
Invoke-WebRequest -Uri $extra4 -OutFile $extractPath\4.json

$malwLessExecutable = Join-Path -Path $extractPath -ChildPath "MalwLess.exe"
1..4 | ForEach-Object {
    $jsonFilePath = Join-Path -Path $extractPath -ChildPath "$_.json"
    $arguments = "-r `"$jsonFilePath`""
    Start-Process -FilePath $malwLessExecutable -ArgumentList $arguments -NoNewWindow -Wait
}

Set-Location -Path "C:\"

Remove-Item -Path $outputPath -Force
Remove-Item -Path $extractPath -Recurse -Force
