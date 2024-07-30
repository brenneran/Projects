param (
    [string]$ArtifactoryUrl = "https://SHUELD_IRL/InstallShield2020R3StandaloneBuild.exe",
    [string]$TargetPath = "C:\Downloads\InstallShield2020R3StandaloneBuild.exe",
    [string]$Username = "$env:CONAN_USER",
    [string]$Password = "$env:CONAN_PASSWORD"
)

# Base64 encode the username and password
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Password}"))

# Invoke the web request to download the file using Invoke-WebRequest
Invoke-WebRequest -Uri $ArtifactoryUrl -OutFile $TargetPath -Headers @{ Authorization = "Basic $base64AuthInfo" } -Method Get


# Define installation arguments for silent installation
$installArguments = "/S /v`"/qn /norestart`""

# Start the installation process
Start-Process -FilePath $TargetPath -ArgumentList $installArguments -Wait

Write-Host "Installation of InstallShield2020R3 is completed"