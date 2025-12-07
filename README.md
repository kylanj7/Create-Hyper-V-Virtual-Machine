# Hyper-V Windows 11 VM Creator

A modular PowerShell script for creating and configuring Windows 11 virtual machines in Hyper-V with idempotent operations.

## Features

- **Idempotent Operations**: Safe to re-run without creating duplicates
- **Modular Design**: Organized into logical components for maintainability
- **Windows 11 Ready**: Includes TPM 2.0, Secure Boot, and UEFI configuration
- **Error Handling**: Graceful handling of common issues
- **Automatic Configuration**: Sets up CPU, memory, storage, and networking

## Project Structure

```
Create-Hyper-V-Virtual-Machine/
├── Create-Windows11VM.ps1      # Main script entry point
├── Modules/
├── VMConfiguration.ps1     # Core VM creation and prerequisites
├── VMStorage.ps1          # VHD creation and attachment
├── VMHardware.ps1         # CPU and memory configuration
├── VMSecurity.ps1         # TPM, Secure Boot, Key Protector
├── VMDVDDrive.ps1         # ISO mounting and boot configuration
├── VMManagement.ps1       # VM operations (start, stop, connect)
└── README.md                  # This file
```

## Usage

### Basic Usage

Run with default settings:
```powershell
.\Create-Windows11VM.ps1
```

### Custom Configuration

```powershell
.\Create-Windows11VM.ps1 -VMName "MyWin11VM" `
                        -VMMemory 16GB `
                        -VMDiskSize 100GB `
                        -VMCPUCount 8 `
                        -ISOPath "C:\ISOs\Win11.iso"
```

### Parameters

- **VMName**: Name of the virtual machine (default: "Windows11-VM")
- **VMPath**: Base path for VM files (default: "C:\Hyper-V\VMs")
- **ISOPath**: Path to Windows 11 ISO file
- **VMMemory**: RAM allocation (default: 8GB)
- **VMDiskSize**: Virtual hard disk size (default: 64GB)
- **VMCPUCount**: Number of virtual CPUs (default: 4)
- **SwitchName**: Hyper-V virtual switch (default: "Default Switch")

## Requirements

- Windows 10/11 Pro or Enterprise with Hyper-V enabled
- PowerShell 5.1 or later (Run as Administrator)
- Windows 11 ISO file
- Sufficient disk space for VM storage
- CPU with virtualization support

## Module Descriptions

### VMConfiguration.ps1
- Creates the VM with Generation 2 settings
- Ensures VM folders exist
- Handles existing VMs gracefully

### VMStorage.ps1
- Creates dynamic VHDX files
- Attaches storage to VM
- Checks for existing disks

### VMHardware.ps1
- Configures CPU count
- Sets memory allocation
- Enables nested virtualization

### VMSecurity.ps1
- Enables TPM 2.0
- Configures Secure Boot
- Sets up Key Protector

### VMDVDDrive.ps1
- Manages DVD drives
- Mounts Windows ISO
- Sets boot order

### VMManagement.ps1
- Starts/stops VMs
- Displays configuration summary
- Launches VM console connection

## Troubleshooting

### Common Issues

1. **"Access Denied" Error**
   - Run PowerShell as Administrator

2. **"Hyper-V not found" Error**
   - Enable Hyper-V feature in Windows Features

3. **TPM/Secure Boot Errors**
   - Ensure your CPU supports these features
   - Check BIOS/UEFI settings

4. **Network Switch Not Found**
   - Create a virtual switch in Hyper-V Manager
   - Or use: `New-VMSwitch -Name "Default Switch" -SwitchType Internal`

## License

This script is provided as-is for educational and personal use.
