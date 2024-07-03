# FuzzMonitor

FuzzMonitor is a powerful shell script designed to monitor processes, detect crashes, and manage core dumps. It helps system administrators and developers keep track of process crashes and configure core dumps efficiently.

## Features

- Monitors specified processes for crashes
- Configures core dumps to be stored in a designated directory
- Provides real-time crash detection and logging
- Automatically manages core dump settings
- User prompts for setting system time and initializing logs

## Getting Started

### Prerequisites

- Linux-based system
- Root privileges to modify system configurations

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/FuzzMonitor.git
    cd FuzzMonitor
    ```

2. Make the script executable:
    ```sh
    chmod +x FuzzMonitor.sh
    ```

## Usage

Run the script with the following syntax:
```sh
syntax: ./FuzzMonitor.sh <process name list>
sample: ./FuzzMonitor.sh "bluetoothd|wpa_supplicant|hostapd|networkmanager|dhclient|wifid|nm-applet|iwlwifi|hcidump|bluez"
```

### Script Options

- **Core Dump Activation**: The script prompts the user to enable core dump settings.
- **System Time Configuration**: Users can manually set the system time if needed.
- **Log Initialization**: Option to initialize the crash log file.

## How It Works

1. **Core Dump Configuration**: The script checks and optionally configures the system for core dumps.
2. **Crash Monitoring**: It continuously monitors specified processes and logs any crashes detected.
3. **Crash Count**: Keeps a count of the number of crashes detected.
4. **Report and Crash Dump Storage**: The crash reports and core dumps are saved in the `fuzz` directory. The crash report file is named `report_crash.log` and the core dumps are stored in the `fuzz/crash` directory.

This `README.md` file includes all the information about the `FuzzMonitor` project, with a clear explanation of how to use the script and where the logs and core dumps are stored.
