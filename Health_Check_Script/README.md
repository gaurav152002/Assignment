# System Health Monitor

A comprehensive Bash script that monitors system health metrics including CPU usage, memory usage, disk space, and running processes. It provides real-time alerts when thresholds are exceeded and logs all activities for historical analysis.

## Features

- **CPU Monitoring**: Tracks CPU usage percentage and alerts when exceeding threshold
- **Memory Monitoring**: Monitors RAM usage with detailed breakdown (total, used, free, available)
- **Disk Space Monitoring**: Checks all mounted filesystems for space usage
- **Process Monitoring**: Tracks total, running, sleeping, and zombie processes
- **System Information**: Displays hostname, OS, kernel version, and uptime
- **Color-Coded Output**: Easy-to-read terminal output with status indicators
- **Logging**: All activities logged to `health_log.txt` with timestamps

## Prerequisites

- Linux/Unix system (Ubuntu, CentOS, macOS, WSL)
- `bash` shell
- Standard utilities: `top`, `free`, `df`, `ps`, `vmstat`, `bc`, `awk`, `uptime`

## Installation

1. Clone or download the repository
2. Navigate to the `Health_Check_Script` folder
3. Make the script executable:

```bash
chmod +x system_health_monitor.sh

Usage
Run the script:
bash
./system_health_monitor.sh
Or with bash:
bash
bash system_health_monitor.sh
Sample Output:
plain
============================================
   SYSTEM HEALTH MONITOR - 2026-06-06 12:30:00
============================================

[1] CPU USAGE
    CPU Usage     : 45%  ✓ Normal
    Top 3 CPU processes:
      chrome                    12.5%
      python3                   8.2%
      docker-desktop            5.1%

[2] MEMORY (RAM) USAGE
    Total Memory  : 16384 MB
    Used Memory   : 8192 MB
    Free Memory   : 2048 MB
    Available     : 6144 MB
    Memory Usage  : 50%  ✓ Normal

[3] DISK SPACE USAGE
    Filesystem       Size  Used  Avail  Use%  Status
    ---------------------------------------------------------------
    /dev/sda1        100G   45G    55G   45%  ✓ OK

[4] RUNNING PROCESSES
    Total Processes  : 245
    Running          : 3
    Sleeping         : 242
    Zombie Processes : 0  ✓ None

[5] SYSTEM INFORMATION
    Hostname         : my-laptop
    OS               : GNU/Linux
    Kernel           : 5.15.0
    Uptime           : up 5 hours, 30 minutes
    Logged In Users  : 1

============================================
  ✓ Health Check Complete!
  Log saved to: health_log.txt
============================================
Configuration
Edit the threshold variables at the top of the script:
bash
CPU_THRESHOLD=80        # Alert if CPU > 80%
MEMORY_THRESHOLD=80     # Alert if Memory > 80%
DISK_THRESHOLD=85       # Alert if Disk > 85%
LOG_FILE="health_log.txt"  # Output log file
Log File Format
The health_log.txt file contains structured logs:
plain
[2026-06-06 12:30:00] [INFO] CPU usage is normal: 45%
[2026-06-06 12:30:00] [INFO] Memory usage is normal: 50%
[2026-06-06 12:30:00] [INFO] Disk usage on /dev/sda1: 45%
[2026-06-06 12:30:00] [INFO] No zombie processes found
[2026-06-06 12:30:00] [INFO] Health check completed successfully
