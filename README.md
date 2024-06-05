# Keycra.sh

## Overview

`keycra.sh` is a shell script designed to manage core dump settings, prompt user interactions for time setting and file initialization, and monitor processes for crashes. It provides a comprehensive solution for enabling and configuring core dumps, as well as logging and detecting process crashes.

## Features

- Checks and enables core dump settings if disabled.
- Configures core dump settings in system files.
- Prompts the user to set the system time manually.
- Initializes log files based on user input.
- Monitors specified processes for crashes and logs crash details.
- Copies core dumps to a user-specified directory for further analysis.

## Prerequisites

- Unix-like operating system (e.g., Linux).
- Superuser (root) privileges to modify system settings.

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/yourrepository.git
    cd yourrepository
    ```

2. Make the script executable:
    ```sh
    chmod +x keycra.sh
    ```

## Usage

Run the script with the following syntax:
```sh
sudo ./keycra.sh <process name list>
