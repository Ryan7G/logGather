# Log locations, add as many as necessary depending on where logs are.
$logLocations = @(
    'C:\Log\location1',
    'C:\Log\location2'
)

# Logs destination
# We will temporarily put the logs into the LogGather dir to organize them.
$destination = 'C:\where\to\store\reports\'
$logGatherOutput = "C:\where\to\store\reports\LogGather_Report-$(Get-Date -Format 'yyyyMMdd hhmmss').zip"

# Log messaging
$successMessage = 'Copying Logs'
$failMessage = 'Unable to find Logs'

function Copy-Log {
    param(
      [String]$OutputDir,
      [String]$LogsDestination,
      [String]$SuccessMessage,
      [String]$FailMessage
    )
}

# Check to make sure we have somewhere to store our logs, if not let's create it.
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory $destination
    Write-Host 'LogGather Directory Created' -fore Green
}

# Here we can specify what filetypes we want to gather.
if (Test-Path $destination) {
    $fileTypes = '*.txt','*.html','*.doc'
    $recentFiles = Get-ChildItem -Path $destination -Recurse -Include $fileTypes | Sort-Object LastWriteTime | Select-Object -Last 5
    $recentFiles | Copy-Item -Destination $destination -Force
    Write-Host $successMessage -Fore Green
} else {
    Write-Host $failMessage -Fore Yellow
}

foreach ($logLocation in $logLocations) {
    Copy-Log -OutputDir $logLocation
}

# Check that LogGather Dir actually contains logs we need
if ((Get-ChildItem $destination | Measure-Object).Count -eq 0) {
    Write-Host $failMessage -Fore Red
    Read-Host -Prompt 'Press enter to exit'
    exit(1)
}

# Compresses the newly copied log files into an archive called "LogGather_Reports"
$compress = @{
    Path = $destination
    CompressionLevel = 'Fastest'
    DestinationPath = $logGatherOutput
}

Compress-Archive @compress -Force

# Clean up files in the LogGather dir
Get-ChildItem $destination -Exclude *.zip | Remove-Item -Force

# Open the LogGather directory in Windows Explorer
Start-Process $destination
