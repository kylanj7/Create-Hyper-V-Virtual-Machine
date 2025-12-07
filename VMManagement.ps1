# VMManagement.ps1
# Module for VM management operations (Start, Stop, Connect, Summary)

function Start-VMAndConnect {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    Write-Host "`nStarting VM..." -ForegroundColor Yellow
    
    # Start the VM
    Start-VM -Name $VMName
    Write-Host "VM started successfully." -ForegroundColor Green
    
    # Wait a moment for VM to initialize
    Start-Sleep -Seconds 1
    
    # Connect to VM console
    Write-Host "Launching VM console..."
    vmconnect.exe localhost $VMName
}

function Show-VMSummary {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    Write-Host "`n=== VM Configuration Summary ===" -ForegroundColor Cyan
    
    # Get VM information
    $vm = Get-VM -Name $VMName
    $processor = Get-VMProcessor -VMName $VMName
    $memory = Get-VMMemory -VMName $VMName
    $firmware = Get-VMFirmware -VMName $VMName
    $dvd = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
    $hdd = Get-VMHardDiskDrive -VMName $VMName -ErrorAction SilentlyContinue
    
    # Display basic information
    Write-Host "`nVM Name: $($vm.Name)" -ForegroundColor White
    Write-Host "State: $($vm.State)" -ForegroundColor White
    Write-Host "Generation: $($vm.Generation)" -ForegroundColor White
    
    # Display hardware
    Write-Host "`nHardware Configuration:" -ForegroundColor Yellow
    Write-Host "  CPUs: $($processor.Count)" -ForegroundColor White
    Write-Host "  Memory: $([math]::Round($memory.Startup/1GB, 2)) GB" -ForegroundColor White
    Write-Host "  Dynamic Memory: $($memory.DynamicMemoryEnabled)" -ForegroundColor White
    
    # Display storage
    if ($hdd) {
        Write-Host "`nStorage:" -ForegroundColor Yellow
        Write-Host "  VHD Path: $($hdd.Path)" -ForegroundColor White
    }
    
    # Display DVD
    if ($dvd) {
        Write-Host "`nDVD Drive:" -ForegroundColor Yellow
        Write-Host "  ISO Path: $($dvd.Path)" -ForegroundColor White
    }
    
    # Display security
    Write-Host "`nSecurity Features:" -ForegroundColor Yellow
    Write-Host "  Secure Boot: $($firmware.SecureBoot)" -ForegroundColor White
    
    $tpm = Get-VMTPM -VMName $VMName -ErrorAction SilentlyContinue
    if ($tpm) {
        Write-Host "  TPM: Enabled" -ForegroundColor White
    } else {
        Write-Host "  TPM: Disabled" -ForegroundColor White
    }
    
    Write-Host "`n=================================" -ForegroundColor Cyan
}

function Stop-VMGracefully {
    param(
        [Parameter(Mandatory)]
        [string]$VMName,
        
        [Parameter()]
        [int]$TimeoutSeconds = 300
    )
    
    $vm = Get-VM -Name $VMName
    
    if ($vm.State -eq 'Running') {
        Write-Host "Shutting down VM gracefully..."
        Stop-VM -Name $VMName -Force:$false -ErrorAction SilentlyContinue
        
        $elapsed = 0
        while ($vm.State -ne 'Off' -and $elapsed -lt $TimeoutSeconds) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            $vm = Get-VM -Name $VMName
        }
        
        if ($vm.State -ne 'Off') {
            Write-Warning "Graceful shutdown timed out. Forcing shutdown..."
            Stop-VM -Name $VMName -Force
        }
    }
}
