 cmd /c set
Enable-WindowsOptionalFeature -FeatureName SMB1Protocol -Online -NoRestart -WarningAction SilentlyContinue
#------------------------------------------------------------------------------------------------------
echo "Add all environmentVariables"
# Define the environment variables
$environmentVariables = @(
    "D:\Buildtools\python\python363x64\",
    "D:\Buildtools\python\python363x64\scripts",
    "C:\Program Files\Conan\conan",
    "C:\Windows\system32",
    "C:\Windows",
    "C:\Windows\System32\Wbem",
    "C:\Windows\System32\WindowsPowerShell\v1.0\",
    "C:\Windows\System32\OpenSSH\",
    "C:\Program Files\Amazon\cfn-bootstrap\",
    "C:\Program Files\Git LFS",
    "C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\",
    "C:\Program Files\Pandoc\",
    "C:\ProgramData\chocolatey\bin",
    "C:\Program Files\dotnet\",
    "C:\Program Files\Git\cmd",
    "C:\Users\Administrator\AppData\Roaming\npm",
    "%USERPROFILE%\.dotnet\tools",
    "C:\Program Files (x86)\National Instruments\Shared\LabVIEW CLI",
    "C:\Program Files\Amazon\AWSCLIV2\"
)

# Convert the environment variables to a single string with semicolons
$environmentString = $environmentVariables -join ";"

# Set the registry key
$registryPath = "HKCU:\Environment"
Set-ItemProperty -Path $registryPath -Name "Path" -Value $environmentString

# Display a message indicating success
Write-Host "Environment variables added to the registry."
#------------------------------------------------------------------------------------------------------
# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
#Install chocolatey packages
choco install git --version=2.33.0.2
choco install notepadplusplus 7zip
choco install git-lfs.install --version=2.7.2
choco install pandoc --version=2.9.2.1
choco install mobaxterm
choco install python39
choco install netfx-4.8-devpack
choco install netfx-4.8.1-devpack
choco install googlechrome --ignore-checksums
choco install chromedriver --ignore-checksums
#------------------------------------------------------------------------------------------------------
echo "Install Python x64 2.7, 3.6.3, 3.7.9 and 3.10.8"
# Define installation parameters for 3.6.3
$pythonVersion = "3.6.3"
$installFolder = "D:\Buildtools\python\python363x64"

# Download the installer (replace the URL with the actual download link)
$url = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"
New-Item -ItemType Directory -Path "C:\Temp"
$installerPath = "C:\Temp\python-$pythonVersion-amd64.exe"
Invoke-WebRequest -Uri $url -OutFile $installerPath

# Install Python
Start-Process -Wait -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "TargetDir=$installFolder"

# Add Python to the PATH environment variable
[Environment]::SetEnvironmentVariable('Path', "$installFolder;$($env:Path)", [EnvironmentVariableTarget]::Machine)

#----------------------------------
# Define installation parameters for Python 3.7.9
echo "Installing Python 3.7.9"
$pythonVersion = "3.7.9"
$installFolder = "D:\Buildtools\python\python379x64"

# Download the installer (replace the URL with the actual download link)
$url = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"
$installerPath = "C:\Temp\python-$pythonVersion-amd64.exe"
Invoke-WebRequest -Uri $url -OutFile $installerPath

# Install Python
Start-Process -Wait -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "TargetDir=$installFolder"

# Add Python to the PATH environment variable
[Environment]::SetEnvironmentVariable('Path', "$installFolder;$($env:Path)", [EnvironmentVariableTarget]::Machine)
#------------------------------------------------------------------------------------------------------
# Define installation parameters for Python 2.7.18
echo "Installing Python 2.7.18"
$pythonVersion = "2.7.18"
$installFolder = "D:\Buildtools\Python27"

# Download the installer (replace the URL with the actual download link)
$url = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion.amd64.msi"
$installerPath = "C:\Temp\python-$pythonVersion.amd64.msi"
Invoke-WebRequest -Uri $url -OutFile $installerPath

# Install Python to the specified directory
Start-Process -Wait -FilePath msiexec.exe -ArgumentList "/i", "`"$installerPath`"", "/quiet", "TARGETDIR=`"$installFolder`""

# Add Python to the PATH environment variable
[Environment]::SetEnvironmentVariable("Path", "$($env:Path);$installFolder", [System.EnvironmentVariableTarget]::Machine)

#------------------------------------------------------------------------------------------------------
# Define installation parameters for Python 3.10.8
echo "Installing Python 3.10.8"
$pythonVersion = "3.10.8"
$installFolder = "D:\Buildtools\Python310"

# Download the installer (replace the URL with the actual download link)
$url = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"
$installerPath = "C:\Temp\python-$pythonVersion-amd64.exe"
Invoke-WebRequest -Uri $url -OutFile $installerPath

# Install Python
Start-Process -Wait -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "TargetDir=$installFolder"
#------------------------------------------------------------------------------------------------------
choco install nodejs
choco install yarn
choco install awscli
choco install nuget.commandline --version=3.4.4
choco install dotnet --version=6.0.3

#------------------------------------------------------------------------------------------------------
echo "Install conan and make login"

choco install conan --version=1.60.1
# Point the conan to the configuration
conan config set storage.path=D:\.conan\packages

# Clean the prev users
conan user --clean

echo "Install conan repo to registry"
# Add remote of conan
conan remote add conan "https://ur_conan_repo.com" --force

# Define the directory path
$directory = "C:\Users\Administrator\.conan"

echo "Checking that conan remote add command is worked"
# Define the file name
$fileName = "registry.txt"

# Construct the full file path
$fullPath = Join-Path -Path $directory -ChildPath $fileName

# Check if the file exists
if (Test-Path -Path $fullPath -PathType Leaf) {
    Write-Host "File $fileName exists in $directory"
} else {
    Write-Host "File $fileName does not exist in $directory"
}

# Cr

$conanuser = $env:CONAN_USER
$conanpass = $env:CONAN_PASSWORD

# Construct the command with the provided username and password
conan user $conanuser -p $conanpass

conan search -r conanrepo

#------------------------------------------------------------------------------------------------------
echo "Install pip"
python -m pip install --upgrade pip --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --upgrade pip
pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org setuptools==58.2.0
pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org conan==1.6.1
#------------------------------------------------------------------------------------------------------
# Install OpenJDK latest using Chocolatey
choco install openjdk

# Find the installed OpenJDK version
$javaInstallationPath = Get-ChildItem -Path "C:\Program Files\OpenJDK\" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$javaVersion = $javaInstallationPath.Name

# Update the system PATH with the relevant Java version
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\Program Files\OpenJDK\$javaVersion\bin", [System.EnvironmentVariableTarget]::Machine)

# Display a message with the installed Java version
Write-Host "Installed OpenJDK version: $javaVersion"

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv
echo "Checking Java is installed and added to EnvironmentVariable"
java -version

#------------------------------------------------------------------------------------------------------
echo "Install Visualstudio 2022"

#First lets install the Visual Studio installer with latest version (required to install the old not supported version of 17.2)

$vsInstallerPathLatest = "C:\Downloads\vs_Professional_latest.exe"

# Install Visual Studio silently
Start-Process -FilePath $vsInstallerPathLatest -ArgumentList "--quiet", "--installerOnly", -Wait

Start-Sleep -Seconds 30

# Define paths and version
$vsInstallerPath = "C:\Downloads\vs_Professional.exe"
$vsConfigFilePath = "C:\Downloads\vs2022.vsconfig"

# Install Visual Studio silently
Start-Process -FilePath $vsInstallerPath -ArgumentList "--norestart", "--passive", "--force", "--removeOos false", "--config", $vsConfigFilePath -Wait

# Check the installation status
$installStatus = $?
if ($installStatus -eq $true) {
    Write-Host "Visual Studio 2022 installation completed successfully."
} else {
    Write-Host "Visual Studio 20222 installation failed. Please check the logs for more information."
}

#------------------------------------------------------------------------------------------------------
echo "Install Visualstudio 2017"

# Define paths and version
$vsInstallerPathold = "C:\Downloads\vs17\vs_Professional.exe"
$vsConfigPathold = "C:\Downloads\vs17\vs2017.vsconfig"
$optionsQuiet = "--quiet"
$optionsConfig = "--config $vsConfigPathold"
$vs17Args = @(
    $optionsConfig,
    $optionsQuiet
)

# Install Visual Studio silently
Start-Process -FilePath $vsInstallerPathold `
    -ArgumentList $vs17Args `
    -Wait -PassThru;

# Check the installation status
$installStatus = $?
if ($installStatus -eq $true) {
    Write-Host "Visual Studio 2017 installation completed successfully."
} else {
    Write-Host "Visual Studio 2017 installation failed. Please check the logs for more information."
}

#------------------------------------------------------------------------------------------------------
echo "Install Concurrency Visualizer for Visual Studio 2017 VSIX"

$vsixPath = "$($env:USERPROFILE)\Microsoft.ConcurrencyVisualizer.Plugin.vsix"
(New-Object Net.WebClient).DownloadFile('https://bucket-to-vs2017.s3.us-west-2.amazonaws.com/Microsoft.ConcurrencyVisualizer.Plugin.vsix', $vsixPath)
"`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\IDE\VSIXInstaller.exe`" /q /a $vsixPath" | out-file ".\install-vsix.cmd" -Encoding ASCII
& .\install-vsix.cmd
#------------------------------------------------------------------------------------------------------
echo "Install AppProjectsTemplates VSIX"

$vsixPath = "$($env:USERPROFILE)\AppProjectsTemplates.vsix"
(New-Object Net.WebClient).DownloadFile('https://bucket-to-vs2017.s3.us-west-2.amazonaws.com/AppProjectsTemplates.Extension+v5.0.vsix', $vsixPath)
"`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\IDE\VSIXInstaller.exe`" /q /a $vsixPath" | out-file ".\install2-vsix.cmd" -Encoding ASCII
& .\install2-vsix.cmd
#------------------------------------------------------------------------------------------------------
echo "Install Microsoft Visual C++ Redistributable"
choco install -y vcredist2008
choco install -y vcredist2010
choco install -y vcredist2012
choco install -y vcredist2013
choco install -y vcredist2015
choco install -y vcredist2017
#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
echo "Run the Intel Complier 2023"
$intelurl = "https://registrationcenter-download.intel.com/akdlm/irc_nas/19153/w_dpcpp-cpp-compiler_p_2023.0.0.25932_offline.exe"
$inteldestination = "C:\Downloads\w_dpcpp-cpp-compiler_p_2023.0.0.25932_offline.exe"
Invoke-WebRequest -Uri $intelurl -OutFile $inteldestination
$inteldestinationzip = "C:\Downloads\w_dpcpp-cpp-compiler_p_2023.0.0.25932_offline.zip"
mv "$inteldestination" "$inteldestinationzip"
$extractedfolder = "C:\Downloads\Intel"
Expand-Archive -Path $inteldestinationzip -DestinationPath $extractedfolder
$bootstrapexe = "C:\Downloads\Intel\bootstrapper.exe"
Start-Process -FilePath $bootstrapexe -ArgumentList "--action install --silent --eula accept -p=NEED_VS2017_INTEGRATION=0 -p=NEED_VS2019_INTEGRATION=0 -p=NEED_VS2022_INTEGRATION=1" -Wait

#------------------------------------------------------------------------------------------------------
echo "Run the Intel Complier 2022"
$intel22url = "https://bucket-to-intel2022.s3.us-west-2.amazonaws.com/w_dpcpp-cpp-compiler_p_2022.2.1.19748_offline.exe"
$intel22destination = "C:\Downloads\w_dpcpp-cpp-compiler_p_2022.2.1.19748_offline.exe"
Invoke-WebRequest -Uri $intel22url -OutFile $intel22destination
$intel22destinationzip = "C:\Downloads\w_dpcpp-cpp-compiler_p_2022.2.1.19748_offline.zip"
mv "$intel22destination" "$intel22destinationzip"
$extractedfolder22 = "C:\Downloads\Intel22"
Expand-Archive -Path $intel22destinationzip -DestinationPath $extractedfolder22
$bootstrapexe22 = "C:\Downloads\Intel22\bootstrapper.exe"
Start-Process -FilePath $bootstrapexe22 -ArgumentList "--action install --silent --eula accept -p=NEED_VS2017_INTEGRATION=1 -p=NEED_VS2019_INTEGRATION=0 -p=NEED_VS2022_INTEGRATION=0" -Wait

#------------------------------------------------------------------------------------------------------
echo "Download and place ZIP's of Playbacks"

# Downloading the Playbacks files
$Playbacks = "https://somebucket_of_playback.s3.us-west-2.amazonaws.com/Playbacks/Playbacks.zip"
$Playbacksdestination = "C:\Downloads\Playbacks.zip"
Invoke-WebRequest -Uri $Playbacks -OutFile $Playbacksdestination
$extractedplaybacks = "C:\ProgramData\Playbacks"
Expand-Archive -Path $Playbacksdestination -DestinationPath $extractedplaybacks
#------------------------------------------------------------------------------------------------------

enable-psremoting -force

# Install AWS CLI
echo "Install AWS CLI"
$dlurl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $dlurl -OutFile $installerPath
Start-Process -FilePath msiexec -Args "/i $installerPath /passive" -Verb RunAs -Wait
Remove-Item $installerPath

# Add AWS CLI installation directory to the Path environment variable
$awsCliPath = "C:\Program Files\Amazon\AWSCLIV2\"
$env:Path += ";$awsCliPath"

aws --version

#------------------------------------------------------------------------------------------------------
Echo "Register Amazon CloudHSM"
# Install and configure Software which used to sign executables 

$url = "https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Windows/AWSCloudHSMClient-latest.msi"
$output = "$env:TEMP\AWSCloudHSMClient-latest.msi"

# Download the installer
Invoke-WebRequest -Uri $url -OutFile $output

# Install the downloaded MSI package
Start-Process msiexec.exe -ArgumentList "/i $output /qn" -Wait

# Register the HSM instance for the build agent with the command:
cd "C:\Program Files\Amazon\CloudHSM\"
.\configure.exe -a IP_ADDRESS
.\configure.exe -m

# Start HSM service and make it start automatically on system startup
Set-Service -Name AWSCloudHSMClient -StartupType Automatic
Start-Service -Name AWSCloudHSMClient
Start-Sleep -Seconds 10

# Add cr for getting access to the HSM instance:
cd "C:\Program Files\Amazon\CloudHSM\tools"

# Configure HSM cr
cd "C:\Program Files\Amazon\CloudHSM\tools"
.\set_cloudhsm_cr.exe --username "$env:HSM_U" --password "$env:HSM_P" #Chaned to cr instead of exe real name

# Add cr to global environment variable
$creds = $env:HSM_U+":"+$env:HSM_P
setx /m n3fips_password $creds

# Refresh env 
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv 

# Import the PK certificate from the HSM cluster
cd "C:\Program Files\Amazon\CloudHSM\"
.\import_key.exe -from HSM -all

#Set up ROOT and CodeSigning certificates
cd "C:\ProgramData\Amazon\CloudHSM"
certutil -addstore "Root" root.crt
certutil -addstore "My" codesign.crt

# Repair certificate store for using  "Cavium Key Storage Provider" 
certutil.exe -f -csp "Cavium Key Storage Provider" -repairstore my "d3e8a9c7b2f0c1a4d5b6e7f8a9c0d1e2" #Randomly generated

#------------------------------------------------------------------------------------------------------
#Install Powershell latest version
echo "Install Powershell 7.4.0"
$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.msi"
$destination = "C:\downloads\PowerShell-7.4.0-win-x64.msi"
Invoke-WebRequest -Uri $url -OutFile $destination
echo "Start the PowerShell Install"
Start-Process -FilePath $destination -ArgumentList "/quiet" -Wait

#------------------------------------------------------------------------------------------------------
echo "Change/Add Registry for app"

$AppRegistryPath = "HKLM:\SOFTWARE\app"
$AppRegistryValues = @{ "N1" = "/A7y1+3z/TpJ2KdL5QmXz9e0UoFvR6WrNlVoW2//kZyA"; "N4" = "Kx7Q3H5rPq1FzLnJb8Wv0+RzA9TgYmLp"; "N6" = "V2F5c0JzU2ZRejY5bTQzU1FvSg==" } #Randomly generated

# Create the registry key if it doesn't exist
New-Item -Path $AppRegistryPath -Force -ErrorAction SilentlyContinue

# Set registry values for App
$AppRegistryValues.Keys | ForEach-Object { Set-ItemProperty -Path $AppRegistryPath -Name $_ -Value $AppRegistryValues[$_] -ErrorAction SilentlyContinue }

#------------------------------------------------------------------------------------------------------

echo "Disable Windows notifications"

$registryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"
$registryKey3 = "ToastEnabled"
Set-ItemProperty -Path $registryPath3 -Name $registryKey3 -Value 0

$registryPath4 = "HKCU:\Control Panel\Desktop"
$registryKey4 = "Win8DpiScaling"
Set-ItemProperty -Path $registryPath4 -Name $registryKey4 -Value 1

$registryPath5 = "HKCU:\Control Panel\Desktop"
$registryKey5 = "LogPixels"
Set-ItemProperty -Path $registryPath5 -Name $registryKey5 -Value 96

# Display a message indicating success
Write-Host "Windows notifications have been disabled."

#------------------------------------------------------------------------------------------------------
# Function to check if Internet Explorer is running and close it if necessary
function Ensure-InternetExplorerClosed {
    $ieProcesses = Get-Process -Name "iexplore" -ErrorAction SilentlyContinue
    if ($ieProcesses) {
        Write-Output "Internet Explorer is running. Closing it now..."
        Stop-Process -Name "iexplore" -Force
        Start-Sleep -Seconds 2
        Write-Output "Internet Explorer has been closed."
    } else {
        Write-Output "Internet Explorer is not running."
    }
}

# Ensure Internet Explorer is closed
Ensure-InternetExplorerClosed

# Define the registry paths for Internet Explorer security zones
$internetZonePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"

# Set the value for enabling file downloads
# 3 is the registry key for the Internet zone
# 1803 is the setting for file downloads: 0 = Enable, 1 = Prompt, 3 = Disable
Set-ItemProperty -Path $internetZonePath -Name "1803" -Value 0

# Restart Internet Explorer to apply changes
function Restart-InternetExplorer {
    Start-Process "iexplore"
}

Write-Output "File download has been enabled in Internet Explorer."

#------------------------------------------------------------------------------------------------------
echo "Specify the path to uuidgen.exe"
# Specify the path to uuidgen.exe
$uuidgenPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64"

# Get the current PATH variable
$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)

# Add the path to uuidgen.exe to the PATH variable
$newPath = $currentPath + ";" + $uuidgenPath

# Set the modified PATH variable
[System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::Machine)

#------------------------------------------------------------------------------------------------------
echo "donetFrostingo"
dotnet new install Cake.Frosting.Template::4.0.0

#------------------------------------------------------------------------------------------------------
# Enable the Force AutoLogon feature in Windows
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name 'ForceAutoLogon' -Value 1

try {
    # Get the current computer's name dynamically
    $hostname = $env:COMPUTERNAME

    # Start the Autologon process with the dynamic hostname
    Start-Process -FilePath "C:\Downloads\Autologon.exe" -ArgumentList "Administrator", $hostname, "password", "/accepteula" -NoNewWindow -Wait -ErrorAction Stop
    Write-Host "Autologon command executed successfully with hostname: $hostname."
} catch {
    Write-Host "Error executing Autologon command: $_"
}

#------------------------------------------------------------------------------------------------------
echo "Adding Root CA"
# Define the path to your certificate
$certificatePath = "C:\Downloads\Root_CA_G2.crt"

# Define the certificate store location
$certStorePath = "Cert:\LocalMachine\Root"

# Import the certificate
Try {
    $cert = Import-Certificate -FilePath $certificatePath -CertStoreLocation $certStorePath -ErrorAction Stop
    Write-Host "Certificate imported successfully into Trusted Root Certification Authorities."
} Catch {
    Write-Host "Error importing certificate: $_"
}

#------------------------------------------------------------------------------------------------------
# Wireless-Networking enable
Install-WindowsFeature -Name Wireless-Networking

#------------------------------------------------------------------------------------------------------
echo "Creating a task for lunchjnlp.bat"
# Define task parameters
$taskName = "jenkins-agent"
$actionPath = "c:\jenkins\lunchjnlp.bat"  # Assuming the correct path to the batch file

# Get the current user's SID for the principal
$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Create a new scheduled task action
# Directly executing the batch file without additional arguments
$action = New-ScheduledTaskAction -Execute "$actionPath"

# Create a principal that specifies running with the highest privileges
$principal = New-ScheduledTaskPrincipal -UserId $currentUserName -LogonType Interactive -RunLevel Highest

# Create settings to configure for Windows Vista, Windows Server 2008
$settings = New-ScheduledTaskSettingsSet -Compatibility V1

# Register the scheduled task
Register-ScheduledTask -Action $action -Principal $principal -Settings $settings -TaskName $taskName

Write-Host "Scheduled task '$taskName' created successfully."

#------------------------------------------------------------------------------------------------------

echo "vars"

# Define environment variables
$envVariables = @{
    "capability_system_builder_command_InstallShield_2020" = "C:\Program Files (x86)\InstallShield\2020 SAB\System\IsCmdBld.exe"
    "capability_system_builder_command_Python_2_7" = "D:\Buildtools\Python27\python.exe"
    "bcapability_system_builder_command_python379x64" = "D:\Buildtools\python\python379x64\python.exe"
    "planRepository_branch" = "master"
    "CONAN_EXE" = "D:\Buildtools\python\python363x64\Scripts\conan.exe"
}

# Add environment variables to the user environment
foreach ($envVar in $envVariables.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($envVar.Key, $envVar.Value, [System.EnvironmentVariableTarget]::User)
}

Write-Host "Environment variables added successfully."

#------------------------------------------------------------------------------------------------------
echo "Stop the Windows Update services"
# Stop the Windows Update service
Stop-Service -Name wuauserv -Force

# Set the startup type of the Windows Update service to Disabled
Set-Service -Name wuauserv -StartupType Disabled

# Disable Windows Update scheduled tasks
Disable-ScheduledTask -TaskName "Microsoft\Windows\WindowsUpdate\*" -TaskPath "\Microsoft\Windows\WindowsUpdate\" -ErrorAction SilentlyContinue

#------------------------------------------------------------------------------------------------------
echo "Install .NET SDK installer"
# Install old version before 6.0.321
choco install dotnetcore-2.1-sdk-5xx --version=2.1.526
choco install dotnet-6.0-runtime
choco install dotnet-6.0-sdk-3xx --version=6.0.317

# Define the URL of the .NET SDK installer
$installerUrl = "https://download.visualstudio.microsoft.com/download/pr/b8d5065e-91db-45dd-acf2-072e069fa773/5e2827455a7b96e406a209d1e022f595/dotnet-sdk-6.0.321-win-x64.exe"

# Define the path where you want to save the installer
$installerPath = "$env:TEMP\sdk-6.0.321-windows-x64-installer.exe"

# Download the installer
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Check if the installer file exists
if (Test-Path $installerPath) {
    # Install .NET SDK silently
    Start-Process -FilePath $installerPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    Write-Output "Installation completed successfully."
} else {
    Write-Error "Failed to download the installer."
}
echo "Downloading and copy to Program Data the .NET 6.0 Desktop Runtime (v6.0.26)"
$url = "https://download.visualstudio.microsoft.com/download/pr/3136e217-e5b7-4899-9b7e-aa52ecb8b108/d74134edaa75e3300f8692660b9fb7b5/windowsdesktop-runtime-6.0.26-win-x64.exe"
$outputPath = "c:\ProgramData\setup\dotnet\windowsdesktop-runtime-6.0.26-win-x64.exe"

# Create the destination directory if it doesn't exist
$destinationDirectory = "c:\ProgramData\setup\dotnet\"
if (-not (Test-Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory -Force
}

# Download the file
Invoke-WebRequest -Uri $url -OutFile $outputPath

# Check if download was successful
if (Test-Path $outputPath) {
    Write-Host "File downloaded successfully."
} else {
    Write-Host "Failed to download the file."
}
#------------------------------------------------------------------------------------------------------
echo ".NET Framework 4.8.1 Runtime download and place to folder"
# Set the URL to download from
$url = "https://go.microsoft.com/fwlink/?linkid=2203305"

# Specify the target directory
$targetDirectory = "C:\ProgramData\setup\dotnet\"

# Set the desired name for the downloaded file
$fileName = "windowsdesktop-netframework-4.8.1-win-x64.exe"

# Combine the directory and filename to form the full path
$targetFilePath = Join-Path -Path $targetDirectory -ChildPath $fileName

# Check if the target directory exists, if not, create it
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory | Out-Null
}

# Download the file
Invoke-WebRequest -Uri $url -OutFile $targetFilePath

Write-Host "Download completed and file saved to: $targetFilePath"
#------------------------------------------------------------------------------------------------------
echo "Install SSH Agent and start"

Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service

# Start the service
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent

# Sleep for 20 seconds
Start-Sleep -Seconds 20

# Check the service status
Get-Service ssh-agent

[Environment]::SetEnvironmentVariable("Path", "C:\Program Files\Git\usr\bin;" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine), [EnvironmentVariableTarget]::Machine)

#------------------------------------------------------------------------------------------------------
echo "Working or CR to LF syntax"
# Read the content of the file with Unix-style line endings
$content = Get-Content -Path "$env:UserProfile\.ssh\id_rsa" -Raw

# Convert Unix-style line endings to Windows-style line endings
$newContent = $content -replace "`r", "`n"

# Write the content back to the file with Windows-style line endings
Set-Content -Path "$env:UserProfile\.ssh\id_rsa" -Value $newContent -NoNewline

#------------------------------------------------------------------------------------------------------
echo "Add a private key to ssh-agent"

# Set up environment variables for SSH
$env:GIT_SSH = "C:\Program Files\Git\usr\bin\ssh.exe"
$env:SSH_AUTH_SOCK = "$env:TEMP\ssh-agent.sock"

# Get the path to your private key from environment variable
$privateKeyPath = "C:\Users\Administrators\.ssh\id_rsa"

# Add SSH private key to agent
ssh-add $privateKeyPath
#------------------------------------------------------------------------------------------------------
echo "Clone repo"
# Specify the directory where you want to clone the repository
$destinationDirectory = "D:\repo"

# Clone the Git repository using SSH
git config --system core.longpaths true
git clone REPO_URL $destinationDirectory