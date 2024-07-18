# Function to get IP address of the device
function Get-IPAddress {
    $ipconfigOutput = ipconfig | Out-String
    $ipRegex = [regex]::Matches($ipconfigOutput, '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b')
    foreach ($match in $ipRegex) {
        Write-Output $match.Value
    }
}

# Function to calculate RAM utilization percentage
function Get-RamUtilization {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $totalMemory = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMemory = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedMemory = $totalMemory - $freeMemory
    return $usedMemory
}

# Get total RAM
function Get-TotalRam{
    $totalRAM = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
    $totalRAMgb = [math]::Round($totalRAM / 1GB, 2)
    return $totalRAMgb
}

#Get total RAM
$totalRAMGB = Get-TotalRam

# Get RAM utilization percentage
$ramUtilization = Get-RamUtilization

# Get drive space
$drive = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
$driveInfo = $drive | Select-Object DeviceID, @{Name="FreeSpace";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}, @{Name="Size";Expression={[math]::Round($_.Size / 1GB, 2)}}

# Get processor information
$processor = Get-WmiObject Win32_Processor
$processorName = $processor.Name
$processorMAC = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -ExpandProperty MACAddress

# Get refresh rate of the screen (primary monitor)
function Get-RefreshRate{
    $videoController = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
    if ($videoController) {
        $refreshRate = $videoController.CurrentRefreshRate
        return "Refresh Rate: $refreshRate Hz"
    } else {
        return "Unable to retrieve monitor details."
    }
}

# Get refresh rate of the screen
$refreshRate = Get-RefreshRate

# Get IP address
$ipAddress = Get-IPAddress

# Get operating system information
$osInfo = Get-WmiObject Win32_OperatingSystem
$osName = $osInfo.Caption
$osVersion = $osInfo.Version

#Creating a JSON for API
$infoJSON = @{
    OperatingSystem = @{
        Name = $osName
        Version = $osVersion
    }
    RAM = @{
        TotalGB = $totalRAMGB
        UtilizationPercent = $ramUtilization
    }
    Processor = @{
        Name = $processorName
        MACAddress = $processorMAC
    }
    Network = @{
        IPAddress = $ipAddress
        RefreshRateHz = $refreshRate
    }
    Drives = @()
}

foreach ($driveItem in $driveInfo) {
    $drive = @{
        DeviceID = $driveItem.DeviceID
        FreeSpace = $driveItem.FreeSpace
        TotalSize = $driveItem.Size
    }
    $infoJSON.Drives+= $drive
}

# Get the script path and create the output file path
$scriptPath = $MyInvocation.MyCommand.Path
$outputFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($scriptPath), "data.json")

# Convert the structure to JSON
$JSON = $infoJSON | ConvertTo-Json

# Write the JSON to the file
Set-Content -Path $outputFilePath -Value $JSON

# Optionally display the path where the file is saved
Write-Host "`n`nJSON file saved to:`t$outputFilePath"