#!/bin/bash
set -e

# Remount the root filesystem in read-write mode
mount -o rw,remount / || { echo "[!] Failed to remount /"; exit 1; }

# Check current core dump setting
echo "[*] Checking current core dump setting..."
current_core_dump=$(ulimit -c)
echo "[*] Current core dump setting: $current_core_dump"

# Enable core dump if it is disabled
if [ "$current_core_dump" -eq 0 ]; then
    echo "[+] Core dump is currently disabled. Enabling core dump..."
    ulimit -c unlimited || { echo "[!] Failed to enable core dump"; exit 1; }
    echo "[+] Core dump enabled."
else
    echo "[!] Core dump is already enabled."
fi

# Backup existing configuration files before modifying
echo "[*] Backing up existing configuration files..."
cp /etc/security/limits.conf /etc/security/limits.conf.bak || { echo "[!] Failed to backup limits.conf"; exit 1; }
cp /etc/sysctl.conf /etc/sysctl.conf.bak || { echo "[!] Failed to backup sysctl.conf"; exit 1; }
echo "[*] Backup completed."

# Configure core dump settings in /etc/security/limits.conf
echo "[*] Configuring core dump settings in /etc/security/limits.conf..."
sed -i 's/\*.*soft.*core.*0/*                soft    core            unlimited/' /etc/security/limits.conf || { echo "[!] Failed to update soft core limit"; exit 1; }
sed -i 's/\*.*hard.*core.*0/*                hard    core            unlimited/' /etc/security/limits.conf || { echo "[!] Failed to update hard core limit"; exit 1; }
echo "[*] Core dump settings configured in /etc/security/limits.conf."

# Configure core dump file pattern in /etc/sysctl.conf
echo "[*] Configuring core dump file pattern in /etc/sysctl.conf..."
if grep -q -F "kernel.core_pattern" /etc/sysctl.conf; then
    sed -i 's|^kernel.core_pattern=.*|kernel.core_pattern=/var/crash/core.%e.%p.%h.%t|' /etc/sysctl.conf || { echo "[!] Failed to update core pattern"; exit 1; }
else
    echo "kernel.core_pattern=/var/crash/core.%e.%p.%h.%t" >> /etc/sysctl.conf || { echo "[!] Failed to add core pattern"; exit 1; }
fi

if grep -q -F "fs.suid_dumpable" /etc/sysctl.conf; then
    sed -i 's|^fs.suid_dumpable=.*|fs.suid_dumpable=1|' /etc/sysctl.conf || { echo "[!] Failed to update suid_dumpable"; exit 1; }
else
    echo "fs.suid_dumpable=1" >> /etc/sysctl.conf || { echo "[!] Failed to add suid_dumpable"; exit 1; }
fi
echo "[*] Core dump file pattern configured in /etc/sysctl.conf."

# Apply changes
echo "[*] Applying sysctl changes..."
sysctl -p || { echo "[!] Failed to apply sysctl changes"; exit 1; }

echo "[*] Core dump configuration process completed."


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
    echo "[*] example: ./keycra.sh \"bluetooth|wifi\""
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
    hour=${user_date:9:2}
    minute=${user_date:11:2}
    second=${user_date:13:2}

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
    ps -ef | grep -i -E $1 | grep -v -E "bash|grep" | ./busybox awk '{print $2, $8}' | sort -n > current_pids.txt

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

    sleep 1
done
