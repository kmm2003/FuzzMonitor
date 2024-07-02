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
./FuzzMonitor.sh <process name list>
```
