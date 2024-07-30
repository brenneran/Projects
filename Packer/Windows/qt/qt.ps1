# Define the URL of the installer and the destination path
$qtInstallerUrl = "https://download.qt.io/archive/online_installers/4.7/qt-unified-windows-x64-4.7.0-online.exe"
$installerPath = "C:\Downloads\qt-unified-windows-x64-4.7.0-online.exe"

# Download the Qt installer
Write-Output "Downloading the Qt installer..."
Invoke-WebRequest -Uri $qtInstallerUrl -OutFile $installerPath

# Verify the installer has been downloaded
if (-not (Test-Path -Path $installerPath)) {
    Write-Error "Failed to download the Qt installer."
    exit 1
}

Write-Output "Qt installer downloaded successfully."

# Unblock the installer file if necessary
Write-Output "Unblocking the installer file..."
Unblock-File -Path $installerPath

# Define the content for qtaccount.ini. Find in qt account.
$qtAccountContent = @"
[QtAccount]
email=email
jwt=token
u=userid
"@

# Define the path to qtaccount.ini
$qtAccountPath = "$env:APPDATA\Qt\qtaccount.ini"

# Create the directory if it doesn't exist
$qtAccountDir = Split-Path -Path $qtAccountPath
if (-not (Test-Path -Path $qtAccountDir -PathType Container)) {
    Write-Output "Creating directory: $qtAccountDir"
    New-Item -Path $qtAccountDir -ItemType Directory -Force | Out-Null
}

# Create the qtaccount.ini file
Write-Output "Creating qtaccount.ini..."
$qtAccountContent | Out-File -FilePath $qtAccountPath -Encoding UTF8

# Set the QTDIR environment variable
[Environment]::SetEnvironmentVariable("QTDIR", "C:\Qt\6.6.3\msvc2019_64", [System.EnvironmentVariableTarget]::Machine)

# Define the command arguments
$rootPath = "C:\Qt"
$arguments = @(
    "--root", $rootPath,
    "--default-answer",
    "--auto-answer", "telemetry-question=Yes,AssociateCommonFiletypes=Yes",
    "--accept-licenses",
    "--accept-obligations",
    "--confirm-command", "install", "qt.qt6.663.win64_msvc2019_64"
)

# Start the installer process
Write-Output "Starting the installer process..."
$installerProcess = Start-Process -FilePath $installerPath -ArgumentList $arguments -PassThru

# Function to check if the installer process is still running
function Wait-ForInstaller {
    param($processId)

    while ($true) {
        # Check if the process is still running
        if (-not (Get-Process -Id $processId -ErrorAction SilentlyContinue)) {
            break
        }
        Write-Output "Waiting for Qt installation to complete..."
        Start-Sleep -Seconds 300
    }
}

# Wait for the installer to complete
Write-Output "Waiting for the installer to complete..."
Wait-ForInstaller -processId $installerProcess.Id

# Define the path to check
$pathToCheck = "C:\Qt\6.6.3\msvc2019_64\bin"

# Wait until the folder exists
Write-Output "Checking if the installation folder exists..."
while (-not (Test-Path -Path $pathToCheck)) {
    Write-Output "Installation folder not found. Waiting..."
    Start-Sleep -Seconds 60
}


# Continue with the next steps of your script here
Write-Output "The folder $pathToCheck has been created. Continuing to the next step..."