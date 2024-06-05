#!/bin/bash

clear

echo "

.########..####.########.....########..########.########.########..######..########..#######..########.
.##.....##..##..##.....##....##.....##.##..........##....##.......##....##....##....##.....##.##.....##
.##.....##..##..##.....##....##.....##.##..........##....##.......##..........##....##.....##.##.....##
.########...##..##.....##....##.....##.######......##....######...##..........##....##.....##.########.
.##.........##..##.....##....##.....##.##..........##....##.......##..........##....##.....##.##...##..
.##.........##..##.....##....##.....##.##..........##....##.......##....##....##....##.....##.##....##.
.##........####.########.....########..########....##....########..######.....##.....#######..##.....##
                                                                                                 
                                                                                          dev. keyme

"

if [ "$#" -ne 1 ]; then
    echo "[!] Please run it again using the method below."
    echo "[*] syntax: ./pid_detector.sh <process name list>"
    echo "[*] example: ./pid_detector.sh \"bluetooth|wifi|can\""
    exit 1
fi

read -p "[+] System Time: $(date). Are you going to set the system time manually? (y/n): " user_input
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

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

    result_time="${month}${day}${hour}${minute}${year}.${second}"
    date $result_time
fi

read -p "[+] Do you want to initialize the report_crash.log file? (y/n): " user_input
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

if [ "$user_input" == "y" ]; then
    echo "" > report_crash.log
    echo "[*] The report_crash.log file has been initialized."
fi

echo "[*] Starting.."
flag=0

while true
do
    ps -ef | grep -i -E $1 | grep -v grep | awk '{print $2, $8}' | sort -n > current_pids.txt

    if [ $flag -eq 0 ]; then
        flag=1
        cp current_pids.txt before_pids.txt
    fi

    diff_output=$(diff before_pids.txt current_pids.txt)
    if [ -z "$diff_output" ]; then
        :
    else
        echo "===================[!] I found a crash in the process!===================" | tee -a report_crash.log
        echo "[+] crash time: $(date)" | tee -a report_crash.log
        echo "------------------------------diff output-------------------------------" | tee -a report_crash.log
        echo "$diff_output" | tee -a report_crash.log
        echo "------------------------------current_pids.txt----------------------------" | tee -a report_crash.log
        cat current_pids.txt | tee -a report_crash.log
        echo "------------------------------before_pids.txt-----------------------------" | tee -a report_crash.log
        cat before_pids.txt | tee -a report_crash.log
        echo "-------------------------------------------------------------------------" | tee -a report_crash.log
        echo "========================================================================="  | tee -a report_crash.log
        echo "
        ...
        " | tee -a report_crash.log
    fi

    cp current_pids.txt before_pids.txt
    sleep 1
done
