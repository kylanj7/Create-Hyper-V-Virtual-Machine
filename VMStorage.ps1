# VMStorage.ps1
# Module for VM storage (VHD) management

function Initialize-VMStorage {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    
    Write-Host "`nConfiguring storage..." -ForegroundColor Yellow
    
    # Create VHD if it doesn't exist
    if (Test-Path $Config.VHDPath) {
        Write-Host "VHD already exists at: $($Config.VHDPath)" -ForegroundColor Yellow
    } else {
        Write-Host "Creating new VHD ($([math]::Round($Config.VMDiskSize/1GB, 2)) GB)..."
        New-VHD -Path $Config.VHDPath -SizeBytes $Config.VMDiskSize -Dynamic | Out-Null
        Write-Host "VHD created successfully." -ForegroundColor Green
    }
    
    # Attach VHD if not already attached
    Attach-VMDisk -VMName $Config.VMName -VHDPath $Config.VHDPath
}

function Attach-VMDisk {
    param(
        [Parameter(Mandatory)]
        [string]$VMName,
        
        [Parameter(Mandatory)]
        [string]$VHDPath
    )
    
    $attached = Get-VMHardDiskDrive -VMName $VMName -ErrorAction SilentlyContinue | 
                Where-Object { $_.Path -eq $VHDPath }
    
    if ($null -eq $attached) {
        Write-Host "Attaching VHD to VM..."
        Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath | Out-Null
        Write-Host "VHD attached successfully." -ForegroundColor Green
    } else {
        Write-Host "VHD already attached to VM." -ForegroundColor Yellow
    }
}
