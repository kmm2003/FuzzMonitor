#!/bin/bash

# Function to increment the crash count
increment_crash_count() {
    crash_count=$((crash_count + 1))
    echo $crash_count > ./fuzz/crash_count.txt
}

# Function to remount the root filesystem in read-write mode
remount_root_rw() {
    echo "[*] Remounting root filesystem in read-write mode..."
    mount -o rw,remount / || { echo "[!] Failed to remount /"; exit 1; }
}

# Function to check and enable core dump
check_enable_core_dump() {
    echo "[*] Checking current core dump setting..."
    current_core_dump=$(ulimit -c)
    echo "[*] Current core dump setting: $current_core_dump"
    if [ "$current_core_dump" -eq 0 ]; then
        echo "[+] Core dump is currently disabled. Enabling core dump..."
        ulimit -c unlimited || { echo "[!] Failed to enable core dump"; exit 1; }
        echo "[+] Core dump enabled."
    else
        echo "[!] Core dump is already enabled."
    fi
}

# Function to backup configuration files
backup_configs() {
    echo "[*] Backing up existing configuration files..."
    cp /etc/security/limits.conf /etc/security/limits.conf.bak || { echo "[!] Failed to backup limits.conf"; exit 1; }
    cp /etc/sysctl.conf /etc/sysctl.conf.bak || { echo "[!] Failed to backup sysctl.conf"; exit 1; }
    echo "[*] Backup completed."
}

# Function to configure core dump settings
configure_core_dump_settings() {
    echo "[*] Configuring core dump settings for root in /etc/security/limits.conf..."
    sed -i 's/root.*soft.*core.*0/root soft core unlimited/' /etc/security/limits.conf || { echo "[!] Failed to update soft core limit for root"; exit 1; }
    sed -i 's/root.*hard.*core.*0/root hard core unlimited/' /etc/security/limits.conf || { echo "[!] Failed to update hard core limit for root"; exit 1; }
    echo "[*] Core dump settings for root configured in /etc/security/limits.conf."

    echo "[*] Configuring core dump settings in /etc/security/limits.conf..."
    sed -i 's/\*.*soft.*core.*0/* soft core unlimited/' /etc/security/limits.conf || { echo "[!] Failed to update soft core limit"; exit 1; }
    sed -i 's/\*.*hard.*core.*0/* hard core unlimited/' /etc/security/limits.conf || { echo "[!] Failed to update hard core limit"; exit 1; }
    echo "[*] Core dump settings configured in /etc/security/limits.conf."
}

# Function to configure core dump file pattern
configure_core_pattern() {
    echo "[*] Configuring core dump file pattern in /etc/sysctl.conf..."
    if grep -q -F "kernel.core_pattern" /etc/sysctl.conf; then
        sed -i 's|^kernel.core_pattern=.*|kernel.core_pattern=/home/root/fuzz/crash/core.%e.%p.%h.%t|' /etc/sysctl.conf || { echo "[!] Failed to update core pattern"; exit 1; }
    else
        echo "kernel.core_pattern=/home/root/fuzz/crash/core.%e.%p.%h.%t" >> /etc/sysctl.conf || { echo "[!] Failed to add core pattern"; exit 1; }
    fi

    if grep -q -F "fs.suid_dumpable" /etc/sysctl.conf; then
        sed -i 's|^fs.suid_dumpable=.*|fs.suid_dumpable=1|' /etc/sysctl.conf || { echo "[!] Failed to update suid_dumpable"; exit 1; }
    else
        echo "fs.suid_dumpable=1" >> /etc/sysctl.conf || { echo "[!] Failed to add suid_dumpable"; exit 1; }
    fi
    echo "[*] Core dump file pattern configured in /etc/sysctl.conf."
}

# Function to apply sysctl changes
apply_sysctl_changes() {
    echo "[*] Applying sysctl changes..."
    sysctl -p || { echo "[!] Failed to apply sysctl changes"; exit 1; }
}

# Function to display the banner
display_banner() {
    echo "

.########.##.....##.########.########....##.....##..#######..##....##.####.########..#######..########.
.##.......##.....##......##.......##.....###...###.##.....##.###...##..##.....##....##.....##.##.....##
.##.......##.....##.....##.......##......####.####.##.....##.####..##..##.....##....##.....##.##.....##
.######...##.....##....##.......##.......##.###.##.##.....##.##.##.##..##.....##....##.....##.########.
.##.......##.....##...##.......##........##.....##.##.....##.##..####..##.....##....##.....##.##...##..
.##.......##.....##..##.......##.........##.....##.##.....##.##...###..##.....##....##.....##.##....##.
.##........#######..########.########....##.....##..#######..##....##.####....##.....#######..##.....##

                                                                                                dev. keyme
    "
}

# Main crash detection function
start_crash_detector() {
    echo "[*] Starting crash detector"
    flag=0

    while true; do
        ps -ef | grep -i -E "$1" | grep -v -E "bash|grep" | awk '{print $2, $8}' | sort -n > ./fuzz/current_pids.log

        if [ $flag -eq 0 ]; then
            flag=1
            cp ./fuzz/current_pids.log ./fuzz/before_pids.log
        fi

        diff_output=$(diff ./fuzz/before_pids.log ./fuzz/current_pids.log)
        if echo "$diff_output" | grep -q '^-[0-9]'; then
            increment_crash_count
            echo "===================[!] A process crash has been detected! [Crash Count: $crash_count]===================" | tee -a ./fuzz/report_crash.log
            echo "[+] Crash time: $(date)" | tee -a ./fuzz/report_crash.log
            echo "$diff_output" | tee -a ./fuzz/report_crash.log
            echo "============================================================================"  | tee -a ./fuzz/report_crash.log
            echo " " | tee -a ./fuzz/report_crash.log
        fi

        cp ./fuzz/current_pids.log ./fuzz/before_pids.log

        sleep 1
    done
}

# Check if the script is run with the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "[!] Please run it again using the method below."
    echo "[*] syntax: ./FuzzMonitor.sh <process name list>"
    echo "[*] example: ./FuzzMonitor.sh \"wpa_supplicant|dhclient|bluetoothd|networkmanager\""
    exit 1
fi

# Remount the root filesystem
remount_root_rw

# Check if a directory called "fuzz" exists in the current path
if [ ! -d "fuzz" ]; then
    echo "[+] Directory 'fuzz' does not exist. Creating directory..."
    mkdir fuzz
    chmod 777 fuzz
    echo "[*] Directory 'fuzz' created."
else
    echo "[!] Directory 'fuzz' already exists."
fi

# Prompt the user to set core dump activation
echo -n -e "[+] Do you want to set the core dump activation setting? (y/n): "
read core_dump_activation
core_dump_activation=$(echo "$core_dump_activation" | tr '[:upper:]' '[:lower:]')

if [ "$core_dump_activation" == "y" ]; then

    mkdir -p ./fuzz/crash
    chmod 777 ./fuzz/crash

    # Check and enable core dump
    check_enable_core_dump

    # Backup configuration files
    backup_configs

    # Configure core dump settings
    configure_core_dump_settings

    # Configure core dump file pattern
    configure_core_pattern

    # Apply sysctl changes
    apply_sysctl_changes
fi

# Display the banner
display_banner

# Print the current system time
echo "[+] System Time: $(date)."

# Prompt the user to manually set the system time
echo -n -e "[+] Are you going to set the system time manually? (y/n): "
read user_input
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

# If user chooses to set the time manually
if [ "$user_input" == "y" ]; then
    echo " [+] Please enter the time to set in the following format."
    echo " [*] syntax: <year><month><date> <hour><min><sec>"
    echo " [*] example: 20240603 101430"
    echo -n -e " [+] please input user time: "
    read user_date
    year=${user_date:0:4}
    month=${user_date:4:2}
    day=${user_date:6:2}
    hour=${user_date:9:2}
    minute=${user_date:11:2}
    second=${user_date:13:2}

    # Format the user input date and time
    result_time="${month}${day}${hour}${minute}${year}.${second}"
    date $result_time
fi

# Prompt the user to initialize the ./fuzz/report_crash.log file
read -p "[+] Do you want to initialize the ./fuzz/report_crash.log file? (y/n): " user_input
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

# If user chooses to initialize the ./fuzz/report_crash.log file
if [ "$user_input" == "y" ]; then
    echo "" > ./fuzz/report_crash.log
    echo "[*] The ./fuzz/report_crash.log file has been initialized."
fi

# Check if the crash count file exists, if not, create it and initialize with 0
if [ ! -f ./fuzz/crash_count.txt ]; then
    echo "0" > ./fuzz/crash_count.txt
fi

# Prompt the user to set core dump activation
read -p "[+] Do you want to set the count setting? (y/n): " count_yn
count_yn=$(echo "$count_yn" | tr '[:upper:]' '[:lower:]')

if [ "$count_yn" == "y" ]; then
    echo "0" > ./fuzz/crash_count.txt
fi

# Read the current crash count
crash_count=$(cat ./fuzz/crash_count.txt)

# Start the main crash detection loop
start_crash_detector "$1"
