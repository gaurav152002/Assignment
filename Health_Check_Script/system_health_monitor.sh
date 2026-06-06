#!/bin/bash

# ============================================================
#  SYSTEM HEALTH MONITOR
#  Monitors CPU, Memory, Disk, and Processes
#  Author: Your Name
#  Usage: bash system_health_monitor.sh
# ============================================================

# ---------- CONFIGURATION (Edit these thresholds) ----------
CPU_THRESHOLD=80        # Alert if CPU usage > 80%
MEMORY_THRESHOLD=80     # Alert if Memory usage > 80%
DISK_THRESHOLD=85       # Alert if Disk usage > 85%
LOG_FILE="health_log.txt"  # Log file name
# -----------------------------------------------------------

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ============================================================
# FUNCTION: Print a section header
# ============================================================
print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}============================================${RESET}"
    echo -e "${CYAN}${BOLD}   SYSTEM HEALTH MONITOR - $TIMESTAMP${RESET}"
    echo -e "${BLUE}${BOLD}============================================${RESET}"
    echo ""
}

# ============================================================
# FUNCTION: Log a message to both console AND log file
# ============================================================
log_message() {
    local level=$1
    local message=$2
    echo "[$TIMESTAMP] [$level] $message" >> "$LOG_FILE"
}

# ============================================================
# FUNCTION: Check CPU Usage
# ============================================================
check_cpu() {
    echo -e "${BOLD}[1] CPU USAGE${RESET}"

    # Get CPU usage percentage (idle% subtracted from 100)
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'%' -f1 2>/dev/null)
    
    # Fallback method if above doesn't work
    if [ -z "$CPU_IDLE" ]; then
        CPU_IDLE=$(vmstat 1 1 | tail -1 | awk '{print $15}')
    fi

    CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc 2>/dev/null || echo "N/A")

    if [ "$CPU_USAGE" = "N/A" ]; then
        echo -e "    CPU Usage     : ${YELLOW}Could not determine${RESET}"
        log_message "WARN" "CPU usage could not be determined"
    elif (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo -e "    CPU Usage     : ${RED}${BOLD}${CPU_USAGE}%  ⚠ ALERT! Exceeds ${CPU_THRESHOLD}%${RESET}"
        log_message "ALERT" "CPU usage is HIGH: ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
    else
        echo -e "    CPU Usage     : ${GREEN}${CPU_USAGE}%  ✓ Normal${RESET}"
        log_message "INFO" "CPU usage is normal: ${CPU_USAGE}%"
    fi

    # Show top 3 CPU-consuming processes
    echo -e "    ${BOLD}Top 3 CPU processes:${RESET}"
    ps aux --sort=-%cpu | awk 'NR>1 && NR<=4 {printf "      %-25s %s%%\n", $11, $3}'
    echo ""
}

# ============================================================
# FUNCTION: Check Memory (RAM) Usage
# ============================================================
check_memory() {
    echo -e "${BOLD}[2] MEMORY (RAM) USAGE${RESET}"

    # Get memory info in MB
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    USED_MEM=$(free -m | awk '/^Mem:/{print $3}')
    FREE_MEM=$(free -m | awk '/^Mem:/{print $4}')
    AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')

    # Calculate usage percentage
    MEM_USAGE=$(echo "scale=1; $USED_MEM * 100 / $TOTAL_MEM" | bc)

    echo -e "    Total Memory  : ${BOLD}${TOTAL_MEM} MB${RESET}"
    echo -e "    Used Memory   : ${USED_MEM} MB"
    echo -e "    Free Memory   : ${FREE_MEM} MB"
    echo -e "    Available     : ${AVAILABLE_MEM} MB"

    if (( $(echo "$MEM_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo -e "    Memory Usage  : ${RED}${BOLD}${MEM_USAGE}%  ⚠ ALERT! Exceeds ${MEMORY_THRESHOLD}%${RESET}"
        log_message "ALERT" "Memory usage is HIGH: ${MEM_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
    else
        echo -e "    Memory Usage  : ${GREEN}${MEM_USAGE}%  ✓ Normal${RESET}"
        log_message "INFO" "Memory usage is normal: ${MEM_USAGE}%"
    fi

    # Show top 3 memory-consuming processes
    echo -e "    ${BOLD}Top 3 Memory processes:${RESET}"
    ps aux --sort=-%mem | awk 'NR>1 && NR<=4 {printf "      %-25s %s%%\n", $11, $4}'
    echo ""
}

# ============================================================
# FUNCTION: Check Disk Space
# ============================================================
check_disk() {
    echo -e "${BOLD}[3] DISK SPACE USAGE${RESET}"

    # Get disk usage for all mounted filesystems
    echo -e "    ${BOLD}Filesystem       Size  Used  Avail  Use%  Status${RESET}"
    echo "    ---------------------------------------------------------------"

    df -h | grep -vE '^Filesystem|tmpfs|cdrom|udev' | while read -r line; do
        USAGE=$(echo "$line" | awk '{print $5}' | cut -d'%' -f1)
        FILESYSTEM=$(echo "$line" | awk '{print $1}')
        SIZE=$(echo "$line" | awk '{print $2}')
        USED=$(echo "$line" | awk '{print $3}')
        AVAIL=$(echo "$line" | awk '{print $4}')
        MOUNT=$(echo "$line" | awk '{print $6}')

        if (( USAGE > DISK_THRESHOLD )); then
            echo -e "    ${RED}${BOLD}${FILESYSTEM}  ${SIZE}  ${USED}  ${AVAIL}  ${USAGE}%  ⚠ ALERT${RESET}"
            echo "[$TIMESTAMP] [ALERT] Disk usage HIGH on ${FILESYSTEM}: ${USAGE}% (threshold: ${DISK_THRESHOLD}%)" >> "$LOG_FILE"
        else
            echo -e "    ${GREEN}${FILESYSTEM}  ${SIZE}  ${USED}  ${AVAIL}  ${USAGE}%  ✓ OK${RESET}"
            echo "[$TIMESTAMP] [INFO] Disk usage on ${FILESYSTEM}: ${USAGE}%" >> "$LOG_FILE"
        fi
    done
    echo ""
}

# ============================================================
# FUNCTION: Check Running Processes
# ============================================================
check_processes() {
    echo -e "${BOLD}[4] RUNNING PROCESSES${RESET}"

    TOTAL_PROCESSES=$(ps aux | wc -l)
    RUNNING=$(ps aux | awk '$8=="R" {count++} END {print count+0}')
    SLEEPING=$(ps aux | awk '$8~/S/ {count++} END {print count+0}')
    ZOMBIE=$(ps aux | awk '$8=="Z" {count++} END {print count+0}')

    echo -e "    Total Processes  : ${BOLD}${TOTAL_PROCESSES}${RESET}"
    echo -e "    Running          : ${GREEN}${RUNNING}${RESET}"
    echo -e "    Sleeping         : ${CYAN}${SLEEPING}${RESET}"

    if (( ZOMBIE > 0 )); then
        echo -e "    Zombie Processes : ${RED}${BOLD}${ZOMBIE}  ⚠ WARNING!${RESET}"
        log_message "WARN" "Zombie processes detected: ${ZOMBIE}"
    else
        echo -e "    Zombie Processes : ${GREEN}0  ✓ None${RESET}"
        log_message "INFO" "No zombie processes found"
    fi
    echo ""
}

# ============================================================
# FUNCTION: System Summary
# ============================================================
check_system_info() {
    echo -e "${BOLD}[5] SYSTEM INFORMATION${RESET}"
    echo -e "    Hostname         : ${BOLD}$(hostname)${RESET}"
    echo -e "    OS               : $(uname -o 2>/dev/null || uname -s)"
    echo -e "    Kernel           : $(uname -r)"
    echo -e "    Uptime           : $(uptime -p 2>/dev/null || uptime)"
    echo -e "    Logged In Users  : $(who | wc -l)"
    echo ""
}

# ============================================================
# MAIN: Run all checks
# ============================================================
print_header
check_system_info
check_cpu
check_memory
check_disk
check_processes

echo -e "${BLUE}${BOLD}============================================${RESET}"
echo -e "${GREEN}${BOLD}  ✓ Health Check Complete!${RESET}"
echo -e "${CYAN}  Log saved to: ${LOG_FILE}${RESET}"
echo -e "${BLUE}${BOLD}============================================${RESET}"
echo ""

log_message "INFO" "Health check completed successfully"
