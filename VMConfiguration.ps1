# VMConfiguration.ps1
# Module for basic VM creation and configuration

function New-HyperVVM {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    
    Write-Host "`nChecking VM prerequisites..." -ForegroundColor Yellow
    
    # Ensure VM folder exists
    New-Item -Path $Config.VMFolder -ItemType Directory -Force | Out-Null
    
    # Check for existing VM
    $existingVM = Get-VM -Name $Config.VMName -ErrorAction SilentlyContinue
    
    if (-not $existingVM) {
        Write-Host "Creating VM '$($Config.VMName)'..."
        $vm = New-VM -Name $Config.VMName `
                     -Path $Config.VMPath `
                     -Generation 2 `
                     -MemoryStartupBytes $Config.VMMemory `
                     -SwitchName $Config.SwitchName
        
        Write-Host "VM created successfully." -ForegroundColor Green
    } else {
        Write-Host "VM '$($Config.VMName)' already exists. Using existing VM." -ForegroundColor Yellow
        $vm = $existingVM
    }
    
    return $vm
}

function Ensure-VMStopped {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    $vm = Get-VM -Name $VMName
    if ($vm.State -ne 'Off') {
        Write-Host "Stopping VM '$VMName' for configuration changes..."
        Stop-VM -Name $VMName -Force | Out-Null
        
        # Wait until VM is completely stopped
        do {
            Start-Sleep -Seconds 1
            $vm = Get-VM -Name $VMName
        } while ($vm.State -ne 'Off')
        
        Write-Host "VM is now stopped." -ForegroundColor Green
    }
}
