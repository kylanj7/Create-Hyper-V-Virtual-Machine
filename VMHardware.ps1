# VMHardware.ps1
# Module for VM hardware configuration (CPU, Memory)

function Set-VMHardwareConfiguration {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    
    Write-Host "`nConfiguring hardware..." -ForegroundColor Yellow
    
    # Set CPU count
    try {
        Set-VMProcessor -VMName $Config.VMName -Count $Config.VMCPUCount -ErrorAction Stop
        Write-Host "CPU count set to: $($Config.VMCPUCount)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not set processor count: $_"
    }
    
    # Set memory configuration
    Set-VMMemory -VMName $Config.VMName `
                 -DynamicMemoryEnabled $false `
                 -StartupBytes $Config.VMMemory
    
    Write-Host "Memory set to: $([math]::Round($Config.VMMemory/1GB, 2)) GB" -ForegroundColor Green
    
    # Enable virtualization extensions (for nested virtualization)
    try {
        Set-VMProcessor -VMName $Config.VMName `
                       -ExposeVirtualizationExtensions $true `
                       -ErrorAction Stop
        Write-Host "Virtualization extensions enabled." -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not enable virtualization extensions: $_"
    }
}

function Get-VMHardwareInfo {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    $vm = Get-VM -Name $VMName
    $proc = Get-VMProcessor -VMName $VMName
    $mem = Get-VMMemory -VMName $VMName
    
    return @{
        VM = $vm
        Processor = $proc
        Memory = $mem
    }
}
