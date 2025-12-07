# Hyper-V Windows 11 VM Creation Script
# Main entry point that orchestrates VM creation

param(
    [Parameter()]
    [string]$VMName = "Windows11-VM",
    
    [Parameter()]
    [string]$VMPath = "C:\Hyper-V\VMs",
    
    [Parameter()]
    [string]$ISOPath = "C:\Users\kylan\Desktop\disk images\Win11_25H2_English_x64.iso",
    
    [Parameter()]
    [Int64]$VMMemory = 8GB,
    
    [Parameter()]
    [Int64]$VMDiskSize = 64GB,
    
    [Parameter()]
    [int]$VMCPUCount = 4,
    
    [Parameter()]
    [string]$SwitchName = "Default Switch"
)

# Import modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\Modules\VMConfiguration.ps1"
. "$scriptPath\Modules\VMStorage.ps1"
. "$scriptPath\Modules\VMHardware.ps1"
. "$scriptPath\Modules\VMSecurity.ps1"
. "$scriptPath\Modules\VMDVDDrive.ps1"
. "$scriptPath\Modules\VMManagement.ps1"

# Create configuration object
$config = @{
    VMName      = $VMName
    VMPath      = $VMPath
    VHDPath     = Join-Path -Path $VMPath -ChildPath "$VMName\$VMName.vhdx"
    VMFolder    = Join-Path -Path $VMPath -ChildPath $VMName
    ISOPath     = $ISOPath
    VMMemory    = $VMMemory
    VMDiskSize  = $VMDiskSize
    VMCPUCount  = $VMCPUCount
    SwitchName  = $SwitchName
}

# Main execution
try {
    Write-Host "=== Hyper-V VM Creation Script ===" -ForegroundColor Cyan
    Write-Host "Creating VM: $($config.VMName)" -ForegroundColor Green
    
    # Create VM
    $vm = New-HyperVVM -Config $config
    
    # Configure storage
    Initialize-VMStorage -Config $config
    
    # Configure hardware
    Set-VMHardwareConfiguration -Config $config
    
    # Configure security (TPM/SecureBoot)
    Set-VMSecurityConfiguration -Config $config
    
    # Configure DVD drive
    Set-VMDVDConfiguration -Config $config
    
    # Display summary
    Show-VMSummary -VMName $config.VMName
    
    # Start and connect to VM
    Start-VMAndConnect -VMName $config.VMName
    
    Write-Host "`nVM creation completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error during VM creation: $_" -ForegroundColor Red
    exit 1
}
