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

## Terminal Example
```sh
[*] Remounting root filesystem in read-write mode...
[*] Checking current core dump setting...
[*] Current core dump setting: 0
[+] Core dump is currently disabled. Enabling core dump...
[+] Core dump enabled.
[*] Backing up existing configuration files...
[*] Backup completed.
[*] Configuring core dump settings for root in /etc/security/limits.conf...
[*] Core dump settings for root configured in /etc/security/limits.conf.
[*] Configuring core dump settings in /etc/security/limits.conf...
[*] Core dump settings configured in /etc/security/limits.conf.
[*] Configuring core dump file pattern in /etc/sysctl.conf...
[*] Core dump file pattern configured in /etc/sysctl.conf.
[*] Applying sysctl changes...
[*] Core dump configuration process completed.

.########.##.....##.########.########....##.....##..#######..##....##.####.########..#######..########.
.##.......##.....##......##.......##.....###...###.##.....##.###...##..##.....##....##.....##.##.....##
.##.......##.....##.....##.......##......####.####.##.....##.####..##..##.....##....##.....##.##.....##
.######...##.....##....##.......##.......##.###.##.##.....##.##.##.##..##.....##....##.....##.########.
.##.......##.....##...##.......##........##.....##.##.....##.##..####..##.....##....##.....##.##...##..
.##.......##.....##..##.......##.........##.....##.##.....##.##...###..##.....##....##.....##.##....##.
.##........#######..########.########....##.....##..#######..##....##.####....##.....#######..##.....##

                                                                                                dev. keyme

[+] System Time: Mon Jun 24 10:14:30 UTC 2024.
[+] Are you going to set the system time manually? (y/n): n
[+] Do you want to initialize the ./fuzz/report_crash.log file? (y/n): y
[*] The ./fuzz/report_crash.log file has been initialized.
[+] Do you want to set the count setting? (y/n): y
```
```sh
[*] Starting crash detector
===================[!] A process crash has been detected! [Crash Count: 1]===================
[+] Crash time: Mon Jun 24 10:20:30 UTC 2024
-700 /usr/bin/bluetoothd
=============================================================================================
```

This `README.md` file includes all the information about the `FuzzMonitor` project, with a clear explanation of how to use the script and where the logs and core dumps are stored.
