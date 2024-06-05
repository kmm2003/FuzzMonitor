#!/bin/bash

# Check current core dump setting
echo "Checking current core dump setting..."
current_core_dump=$(ulimit -c)
echo "Current core dump setting: $current_core_dump"

# Enable core dump if it is disabled
if [ "$current_core_dump" -eq 0 ]; then
    echo "Core dump is currently disabled. Enabling core dump..."
    ulimit -c unlimited
    echo "Core dump enabled."
else
    echo "Core dump is already enabled."
fi

# Backup existing configuration files before modifying
echo "Backing up existing configuration files..."
cp /etc/security/limits.conf /etc/security/limits.conf.bak
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo "Backup completed."

# Configure core dump location in /etc/security/limits.conf
echo "Configuring core dump settings in /etc/security/limits.conf..."
if ! grep -q "\* soft core unlimited" /etc/security/limits.conf; then
    echo "* soft core unlimited" >> /etc/security/limits.conf
fi
if ! grep -q "\* hard core unlimited" /etc/security/limits.conf; then
    echo "* hard core unlimited" >> /etc/security/limits.conf
fi
echo "Core dump settings configured in /etc/security/limits.conf."

# Configure core dump file pattern in /etc/sysctl.conf
echo "Configuring core dump file pattern in /etc/sysctl.conf..."
if ! grep -q "kernel.core_pattern" /etc/sysctl.conf; then
    echo "kernel.core_pattern=/var/crash/core.%e.%p.%h.%t" >> /etc/sysctl.conf
fi
if ! grep -q "fs.suid_dumpable" /etc/sysctl.conf; then
    echo "fs.suid_dumpable = 1" >> /etc/sysctl.conf
fi
echo "Core dump file pattern configured in /etc/sysctl.conf."

# Apply changes
echo "Applying sysctl changes..."
sysctl -p

echo "Core dump configuration process completed."

# Clear the terminal screen
clear

# Display a banner
echo "

                                                                        
 ##  ##   ######   ##  ##    ####    #####      ##      #####   ##  ##  
 ## ##    ##       ##  ##   ##  ##   ##  ##    ####    ###      ##  ##  
 ####     ####      ####    ##       ##  ##   ##  ##    ###     ######  
 ####     ##         ##     ##       #####    ######     ###    ##  ##  
 ## ##    ##         ##     ##  ##   ## ##    ##  ##      ###   ##  ##  
 ##  ##   ######     ##      ####    ##  ##   ##  ##   #####    ##  ##  
                                                                        
                                                                                                 
                                                                 dev. keyme
"

# Check if the script is run with the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "[!] Please run it again using the method below."
    echo "[*] syntax: ./keycra.sh <process name list>"
    echo "[*] example: ./keycra.sh \"bluetooth|wifi|can\""
    exit 1
fi

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
    hour=${user_date:8:2}
    minute=${user_date:10:2}
    second=${user_date:12:2}

    # Format the user input date and time
    result_time="${month}${day}${hour}${minute}${year}.${second}"
    date $result_time
fi

# Prompt the user to initialize the report_crash.log file
read -p "[+] Do you want to initialize the report_crash.log file? (y/n): " user_input
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

# If user chooses to initialize the report_crash.log file
if [ "$user_input" == "y" ]; then
    echo "" > report_crash.log
    echo "[*] The report_crash.log file has been initialized."
fi

echo "[*] Starting crash detector"
flag=0

# Main loop for monitoring crashes
while true
do
    # Get the current process IDs and their executable names, then sort them
    ps -ef | grep -i -E $1 | grep -v grep | ./busybox awk '{print $2, $8}' | sort -n > current_pids.txt

    # If it's the first iteration, initialize the before_pids.txt file
    if [ $flag -eq 0 ]; then
        flag=1
        cp current_pids.txt before_pids.txt
    fi

    # Compare the current and previous process IDs to detect crashes
    diff_output=$(diff before_pids.txt current_pids.txt)
    if [ -z "$diff_output" ]; then
        :
    else
        # Log the crash details
        echo "===================[!] I found a crash in the process!===================" | tee -a report_crash.log
        echo "[+] crash time: $(date)" | tee -a report_crash.log
        echo "$diff_output" | tee -a report_crash.log
        echo "========================================================================="  | tee -a report_crash.log
        echo " " | tee -a report_crash.log
    fi

    # Update the before_pids.txt file for the next iteration
    cp current_pids.txt before_pids.txt

    # Copy core dumps to the crash directory in the home folder
    cp -r /var/crash/* ~/crash/
    sleep 1
done
