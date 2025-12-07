# VMSecurity.ps1
# Module for VM security configuration (TPM, Secure Boot, Key Protector)

function Set-VMSecurityConfiguration {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    
    Write-Host "`nConfiguring security features..." -ForegroundColor Yellow
    
    # Ensure VM is stopped before making firmware/TPM changes
    Ensure-VMStopped -VMName $Config.VMName
    
    # Configure Key Protector
    Configure-VMKeyProtector -VMName $Config.VMName
    
    # Enable TPM
    Enable-VMTPMSupport -VMName $Config.VMName
    
    # Configure Secure Boot
    Configure-VMSecureBoot -VMName $Config.VMName
}

function Configure-VMKeyProtector {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    try {
        $keyProtector = Get-VMKeyProtector -VMName $VMName -ErrorAction SilentlyContinue
        
        if ($null -eq $keyProtector) {
            Write-Host "Adding local key protector..."
            Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector | Out-Null
            Write-Host "Key protector added successfully." -ForegroundColor Green
        } else {
            Write-Host "Key protector already configured." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "Key protector configuration failed: $_"
    }
}

function Enable-VMTPMSupport {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    try {
        $tpm = Get-VMTPM -VMName $VMName -ErrorAction SilentlyContinue
        
        if ($null -eq $tpm) {
            Write-Host "Enabling TPM..."
            Enable-VMTPM -VMName $VMName | Out-Null
            Write-Host "TPM enabled successfully." -ForegroundColor Green
        } else {
            Write-Host "TPM already enabled." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "TPM configuration failed: $_"
    }
}

function Configure-VMSecureBoot {
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )
    
    try {
        Set-VMFirmware -VMName $VMName -EnableSecureBoot On | Out-Null
        Write-Host "Secure Boot enabled." -ForegroundColor Green
    }
    catch {
        Write-Warning "Secure Boot configuration failed: $_"
    }
}
