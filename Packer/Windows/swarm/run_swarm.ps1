# Set the working directory and authentication token
$workDir = "C:\Prod\Jenkins"
$token = "b2d7e4f6a8c1d9b0f3e5a6c7d8e9f0a1"

try {
    # Attempt to download user data from the SOME_IP and save it as a JSON file in the working directory
    Invoke-WebRequest -URI http://SOME_IP/latest/user-data -OutFile $workDir\user_data.json
    # Read the JSON content from the user_data.json and convert it from JSON format
    $jsonContent = Get-Content -Path $workDir\user_data.json -Raw | ConvertFrom-Json
} catch {
    # If there's an error during the download or conversion, create an empty JSON object
	$jsonContent = @() | ConvertTo-Json
}

# Check if the user_data.json content contains a property named "labels"
if ($jsonContent.PSObject.Properties.Name -contains "labels") {
	# Retrieve 'label' value from the dictionary
    $labelValue = $jsonContent.labels
    # Run the Jenkins swarm client with the specified parameters, including the retrieved labels
    Java -jar $workDir\swarm-client.jar -master https://your_jenkins.com -webSocket -username svc.auto_user  -password $token -mode exclusive -fsroot $workDir -deleteExistingClients -name shield_vm -labels $labelValue -executors 1 
} else {
    # If the 'labels' property is not found, create an empty text file in the working directory
	New-Item -Path $workDir -Name "UserDataEmpty.txt" -ItemType File
}

