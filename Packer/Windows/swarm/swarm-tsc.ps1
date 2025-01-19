# Download the swarm-client.jar file
$url = "https://your-jenkins.com/swarm/swarm-client.jar"
$outputPath = "C:\Prod\Jenkins\swarm-client.jar"
Invoke-WebRequest -Uri $url -OutFile $outputPath

# Check if the download was successful
if (Test-Path $outputPath) {
    Write-Output "swarm-client.jar downloaded successfully."
} else {
    Write-Error "Failed to download swarm-client.jar from $url"
    exit 1
}

# Ensure the directory for the XML file exists
$xmlFilePath = "C:\Downloads\swarm\swarm.xml"
$xmlDirectory = [System.IO.Path]::GetDirectoryName($xmlFilePath)
if (-Not (Test-Path $xmlDirectory)) {
    New-Item -Path $xmlDirectory -ItemType Directory | Out-Null
}

# Get the current computer name
$computerName = $env:COMPUTERNAME
$author = "$computerName\Administrator"

# Get the SID of the current user
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$userSID = (New-Object System.Security.Principal.SecurityIdentifier($currentUser.User)).Value

# XML content with dynamic author and user SID
$xmlContent = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffffff')</Date>
    <Author>$author</Author>
    <URI>\run swarm</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$userSID</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>"C:\Prod\Jenkins\run_swarm.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

# Save the XML content to a file with UTF-16 encoding
$xmlContent | Out-File -FilePath $xmlFilePath -Encoding Unicode

# Ensure the XML file exists
if (-Not (Test-Path $xmlFilePath)) {
    Write-Error "The XML file at $xmlFilePath does not exist."
    exit 1
}

# Import the XML into Task Scheduler and capture the output
$createTaskOutput = schtasks.exe /Create /XML $xmlFilePath /TN "SwarmTask" 2>&1

# Check if the task was created successfully
if ($createTaskOutput -notmatch "SUCCESS") {
    Write-Error "Failed to create the Task Scheduler task: $createTaskOutput"
    exit 1
}

# Check if the task exists
$taskExistsOutput = schtasks.exe /Query /TN "SwarmTask" /FO LIST /V 2>&1

# Using regex to match the exact task name
if ($taskExistsOutput -match "TaskName:\s+\\SwarmTask\b") {
    Write-Output "Task Scheduler task 'SwarmTask' created successfully."
} else {
    Write-Error "Failed to verify the Task Scheduler task: $taskExistsOutput"
}