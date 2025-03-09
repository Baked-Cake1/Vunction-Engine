# Vunction Engine by BakedCake wih source code explained.

# Path to configuration files
$configDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pathFile = Join-Path $configDir "Path.txt"
$usernameFile = Join-Path $configDir "UserName.txt"
$usedFile = Join-Path $configDir "Used.txt"

# Function to compute SHA-256 hash of a file
function Get-FileHash256 {
    param (
        [string]$filePath
    )
    $hash = Get-FileHash -Algorithm SHA256 -Path $filePath
    return $hash.Hash
}

# Function to load hashes from a file
function Load-Hashes {
    param (
        [string]$filePath
    )
    if (Test-Path $filePath) {
        return Get-Content $filePath
    }
    return @()
}

# Function to get a random greeting
function Get-Greeting {
    $greetings = @("Welcome", "Welcome back", "Howdy", "G'day")
    $timeBasedGreetings = @()

    # Get current hour
    $hour = (Get-Date).Hour

    # Add time-based greetings
    if ($hour -ge 5 -and $hour -lt 12) {
        $timeBasedGreetings += "Good morning"
    }
    elseif ($hour -ge 12 -and $hour -lt 18) {
        $timeBasedGreetings += "Good afternoon"
    }
    else {
        $timeBasedGreetings += "Good evening"
    }

    # Combine all greetings
    $allGreetings = $greetings + $timeBasedGreetings

    # Randomly select a greeting
    return $allGreetings | Get-Random
}

# Check if configuration files exist, create them if not
if (-not (Test-Path $pathFile)) {
    Write-Host "Path.txt not found. Creating it..."
    Set-Content -Path $pathFile -Value "C:\Program Files\Vex's Antivirus"
}

if (-not (Test-Path $usernameFile)) {
    Write-Host "UserName.txt not found. Creating it..."
    Set-Content -Path $usernameFile -Value "User"
}

if (-not (Test-Path $usedFile)) {
    Write-Host "Used.txt not found. Creating it..."
    Set-Content -Path $usedFile -Value "0"
}

# Read configuration files
$basePath = Get-Content -Path $pathFile
$username = Get-Content -Path $usernameFile
$used = Get-Content -Path $usedFile

# Set paths for hash files
$suspiciousHashesPath = Join-Path $basePath "SuspiciousHashes.txt"
$maliciousHashesPath = Join-Path $basePath "MaliciousHashes.txt"

# Main script loop
while ($true) {
    # Load suspicious and malicious hashes
    $suspiciousHashes = Load-Hashes -filePath $suspiciousHashesPath
    $maliciousHashes = Load-Hashes -filePath $maliciousHashesPath

    # Initialize counters
    $totalFilesScanned = 0
    $totalFoldersScanned = 0
    $dangerousFiles = @()

    # Greet the user
    $greeting = Get-Greeting
    if ($used -eq "0") {
        Write-Host "$greeting, $username."
        Set-Content -Path $usedFile -Value "1"
    }
    else {
        Write-Host "$greeting, $username."
    }

    # Prompt user for directory to scan
    $directoryToScan = Read-Host "Enter the directory to scan (e.g., C:\Users\YourName\Documents)"

    # Get all files in the directory and subdirectories
    $allFiles = Get-ChildItem -Path $directoryToScan -Recurse -File
    $totalFiles = $allFiles.Count
    $totalSizeMB = ($allFiles | Measure-Object -Property Length -Sum).Sum / 1MB

    # Scan directory and subdirectories
    foreach ($file in $allFiles) {
        $totalFilesScanned++
        $fileSizeMB = $file.Length / 1MB
        $remainingSizeMB = $totalSizeMB - ($allFiles[0..($totalFilesScanned - 1)] | Measure-Object -Property Length -Sum).Sum / 1MB

        # Compute SHA-256 hash
        $fileHash = Get-FileHash256 -filePath $file.FullName

        # Display file name and hash
        Write-Host "Scanning file: $($file.FullName) | Hash: $fileHash"

        # Check against suspicious hashes
        if ($suspiciousHashes -contains $fileHash) {
            $dangerousFiles += $file.FullName
            Write-Host "Dangerous file detected: $($file.FullName)" -ForegroundColor Red
        }
        # Check against malicious hashes
        elseif ($maliciousHashes -contains $fileHash) {
            $dangerousFiles += $file.FullName
            Write-Host "Dangerous file detected: $($file.FullName)" -ForegroundColor Red
        }

        # Display progress
        $percentComplete = [math]::Round(($totalFilesScanned / $totalFiles) * 100, 2)
        Write-Host "Progress: $percentComplete% | Files left: $($totalFiles - $totalFilesScanned) | Remaining size: $([math]::Round($remainingSizeMB, 2)) MB`n"
    }

    # Scan folders (for counting purposes)
    $totalFoldersScanned = (Get-ChildItem -Path $directoryToScan -Recurse -Directory).Count

    # Display summary
    Write-Host "`nScan completed!"
    Write-Host "Total files scanned: $totalFilesScanned"
    Write-Host "Total folders scanned: $totalFoldersScanned"

    if ($dangerousFiles.Count -gt 0) {
        Write-Host "`nDangerous files detected:" -ForegroundColor Red
        $dangerousFiles | ForEach-Object { Write-Host $_ }

        # Prompt user for action
        $userInput = Read-Host "`nType 'delete' to delete all dangerous files or 'cancel' to restart the script"
        if ($userInput -eq "delete") {
            $dangerousFiles | ForEach-Object {
                Remove-Item -Path $_ -Force
                Write-Host "Deleted: $_" -ForegroundColor Green
            }
            Write-Host "All dangerous files have been deleted." -ForegroundColor Green
        }
        elseif ($userInput -eq "cancel") {
            Write-Host "Restarting script..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            continue
        }
        else {
            Write-Host "Invalid input. Restarting script..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            continue
        }
    }
    else {
        Write-Host "No dangerous files detected. Restarting script..." -ForegroundColor Green
        Start-Sleep -Seconds 2
        continue
    }
}