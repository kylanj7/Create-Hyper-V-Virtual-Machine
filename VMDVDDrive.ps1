# VMDVDDrive.ps1
# Module for VM DVD drive and ISO management

function Set-VMDVDConfiguration {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    
    Write-Host "`nConfiguring DVD drive..." -ForegroundColor Yellow
    
    # Clean up existing DVD drives
    Remove-ExtraDVDDrives -VMName $Config.VMName -TargetISOPath $Config.ISOPath
    
    # Add DVD drive with ISO
    $dvd = Add-VMDVDWithISO -VMName $Config.VMName -ISOPath $Config.ISOPath
    
    # Set as first boot device
    Set-VMFirstBootDevice -VMName $Config.VMName -DVDDrive $dvd
}

function Remove-ExtraDVDDrives {
    param(
        [Parameter(Mandatory)]
        [string]$VMName,
        
        [Parameter(Mandatory)]
        [string]$TargetISOPath
    )
    
    $dvds = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
    
    if ($dvds) {
        # Remove extra DVD drives or those with different ISOs
        if ($dvds.Count -gt 1) {
            Write-Host "Removing extra DVD drives..."
            foreach ($dvd in $dvds) {
                Remove-VMDvdDrive -VMName $VMName `
                                 -ControllerNumber $dvd.ControllerNumber `
                                 -ControllerLocation $dvd.ControllerLocation `
                                 -ErrorAction SilentlyContinue
            }
        } elseif ($dvds.Path -and ($dvds.Path -ne $TargetISOPath)) {
            Write-Host "Removing DVD drive with different ISO..."
            Remove-VMDvdDrive -VMName $VMName `
                             -ControllerNumber $dvds.ControllerNumber `
                             -ControllerLocation $dvds.ControllerLocation `
                             -ErrorAction SilentlyContinue
        } else {
            Write-Host "Existing DVD drive configuration is correct." -ForegroundColor Yellow
            return
        }
    }
}

function Add-VMDVDWithISO {
    param(
        [Parameter(Mandatory)]
        [string]$VMName,
        
        [Parameter(Mandatory)]
        [string]$ISOPath
    )
    
    Write-Host "Adding DVD drive with ISO: $ISOPath"
    $dvd = Add-VMDvdDrive -VMName $VMName -Path $ISOPath -Passthru
    
    # Handle if multiple drives are returned
    if ($dvd -is [System.Array]) { 
        $dvd = $dvd[0] 
    }
    
    Write-Host "DVD drive added successfully." -ForegroundColor Green
    return $dvd
}

function Set-VMFirstBootDevice {
    param(
        [Parameter(Mandatory)]
        [string]$VMName,
        
        [Parameter(Mandatory)]
        $DVDDrive
    )
    
    try {
        Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive | Out-Null
        Write-Host "First boot device set to DVD drive." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to set first boot device: $_"
    }
}
