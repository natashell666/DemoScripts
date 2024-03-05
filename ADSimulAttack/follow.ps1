param(
    [string]$username
)

$urls = @(
    "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/mimikatz.json",
    "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/active-guest-acccount-admin.json",
    "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/js-dropper.json",
    "https://github.com/n0dec/MalwLess/raw/master/sets/APTSimulator/wmi-backdoor-c2.json",
    "https://github.com/n0dec/MalwLess/raw/master/sets/ATT%26CK/T1003.json",
    "https://github.com/n0dec/MalwLess/raw/master/sets/ATT%26CK/T1018.json",
    "https://github.com/n0dec/MalwLess/raw/master/sets/windows-oneliners.json"
)

$downloadUrl = "https://github.com/n0dec/MalwLess/releases/download/latest/malwless.zip"
$outputPath = "C:\demo\malwless.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

$extractPath = "C:\demo\Malware"
Expand-Archive -Path $outputPath -DestinationPath $extractPath -Force
Set-Location -Path $extractPath

$jsonFilesPath = "C:\demo"
foreach ($index in 1..$urls.Count) {
    Invoke-WebRequest -Uri $urls[$index - 1] -OutFile "$jsonFilesPath\$index.json"
}

1..7 | ForEach-Object {
    $jsonFilePath = Join-Path -Path $jsonFilesPath -ChildPath "$_.json"
    $jsonDestPath = Join-Path -Path $extractPath -ChildPath "$_.json"
    if (Test-Path $jsonFilePath) {
        $content = Get-Content -Path $jsonFilePath -Raw
        $modifiedContent = $content.Replace("Administrator", $username).Replace("ADMINI~1", $username)
        Set-Content -Path $jsonDestPath -Value $modifiedContent
    } else {
        Write-Warning "File $jsonFilePath doesn't exist."
    }
}

$malwLessExecutable = Join-Path -Path $extractPath -ChildPath "MalwLess.exe"
1..7 | ForEach-Object {
    $jsonFilePath = Join-Path -Path $extractPath -ChildPath "$_.json"
    $arguments = "-r `"$jsonFilePath`""
    Start-Process -FilePath $malwLessExecutable -ArgumentList $arguments -NoNewWindow -Wait
}

Set-Location -Path "C:\"
Remove-Item -Path $jsonFilesPath\*.json -Force
Remove-Item -Path $outputPath -Force
Remove-Item -Path $extractPath -Recurse -Force
