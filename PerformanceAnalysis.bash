# ============================================================================
# PerformanceAnalysis.bash - CPU, Memory, and Disk I/O Performance Commands
# Purpose: Debug CPU usage, memory, disk performance, and process bottlenecks
# Target: Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+, Container environments
# ============================================================================

# Command 1: Check system load and CPU cores
# Usage: When you need a quick overview of system load and CPU capacity
uptime

# Output example:
# 15:45:23 up 5 days, 3:22, 2 users, load average: 1.23, 0.98, 0.87
# or:
# 15:45:23 up 5 days, 3:22, 2 users, load average: 1.23, 0.98, 0.87
#
# Interpretation: System has been up 5 days. Load average 1.23 means 1.23 processes
# queued over last minute. Compare to CPU count: 4 CPUs × 1.0 = fully loaded.


# Command 2: Check CPU usage by process (find CPU hogs)
# Usage: When a process is consuming excessive CPU
top -b -n 1 | head -20
# or for sorted output:
ps aux --sort=-%cpu | head -10

# Output example:
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root      1234 85.2  5.3  512000 55000 ?      S    10:00  45:32 python /app/worker.py
# user      5678 12.1  2.1  256000 22000 ?      S    14:23   2:15 java -Xmx1g App
# root       999  5.3  1.2  128000 12000 ?      S    11:00   1:45 nginx
#
# Interpretation: Python worker using 85.2% CPU, Java using 12.1%.
# If > 100%, process has multiple threads. High %CPU + high TIME = runaway process.


# Command 3: Check memory utilization
# Usage: When you need to see total memory usage and free memory
free -h
# or verbose:
free -h | grep Mem

# Output example:
#               total        used        free      shared  buff/cache   available
# Mem:          15Gi        8.5Gi       2.1Gi      256Mi       4.4Gi       6.2Gi
# Swap:         2.0Gi       512Mi       1.5Gi
#
# Interpretation: 15GB total, 8.5GB used (57%), 2.1GB free (14%).
# buff/cache (4.4GB) is reclaimed if needed. Watch swap usage—high swap = memory pressure.


# Command 4: Check memory usage by process (find memory hogs)
# Usage: When a process is consuming excessive memory
ps aux --sort=-%mem | head -10

# Output example:
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# postgres  2345  0.5 42.1 8500000 6400000 ?     S    08:00 120:34 /usr/lib/postgres
# app       3456  1.2 25.3 4000000 3800000 ?     S    09:15  45:23 java -Xmx3g server
# redis     4567  0.1  8.2 1200000 1240000 ?     S    07:30   5:12 redis-server
#
# Interpretation: Postgres using 42% of 15GB = 6.3GB RSS. If RSS keeps growing,
# there's a memory leak.


# Command 5: Check disk usage and identify full filesystems
# Usage: When you need to see disk space on all mounted filesystems
df -h

# Output example:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1       20G   18G   1.2G  94% /
# /dev/sda2       50G   45G   3.2G  91% /home
# tmpfs           7.5G  128M  7.4G   2% /dev/shm
#
# Interpretation: Root filesystem at 94% capacity (1.2GB free).
# Approaching danger zone. Clean up old logs or temp files. Filesystem at 100% causes outages.


# Command 6: Find large files and directories taking up space
# Usage: When you need to identify what's using disk space
du -sh /* | sort -h | tail -10
# or find largest files:
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | head -10

# Output example:
# 8.5G	/var
# 3.2G	/usr
# 2.1G	/home
# 1.5G	/opt
#
# Interpretation: /var using 8.5GB, mostly from logs. /opt has 1.5GB application data.
# Run `du -sh /var/*` to drill down further.


# Command 7: Check disk I/O performance (iostat)
# Usage: When disk performance is slow or you suspect I/O bottleneck
iostat -x 1 5
# or simple disk reads/writes:
iostat -d 1 5

# Output example:
# avg-cpu:  %user   %nice %system %iowait  %steal   %idle
#           15.23    0.00   8.45   2.12    0.00   74.20
# Device     r/s     w/s    rMB/s    wMB/s
# sda       120.5   234.3    12.1    15.3
# sdb        45.2    89.1     3.2     5.1
#
# Interpretation: sda doing 120 reads/sec, 234 writes/sec. %iowait 2.12% = low I/O wait.
# If %iowait > 10%, disk is the bottleneck.


# Command 8: Check memory pages and swap activity
# Usage: When you suspect memory paging is affecting performance
vmstat 1 5

# Output example:
# procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
#  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
#  2  0      0 2100000 230000 4400000   0   0    45   120 1234 5678 15  8 74  2  0
#  1  0      0 2090000 230000 4410000   0   0    32    95 1250 5690 12  7 75  3  0
#
# Interpretation: r=2 (runnable processes), b=0 (blocked). si/so = swap in/out (both 0 = good).
# bi/bo = block I/O. If si > 0, system is paging (memory pressure).


# Command 9: Monitor running processes in real-time
# Usage: When you need live process monitoring with updates
top
# or less interactive:
htop

# Output example:
# PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
# 1234 root      20   0 512000  55000  12000 S  85.2  5.3   45:32 python
# 5678 user      20   0 256000  22000   8000 S  12.1  2.1    2:15 java
# 999  root      20   0 128000  12000   5000 S   5.3  1.2    1:45 nginx
#
# Interpretation: Press 'q' to quit. 'M' sorts by memory, 'P' by CPU.
# Hit SHIFT+F to add/remove columns.


# Command 10: Check context switching and system calls
# Usage: When you suspect high kernel overhead slowing down processes
vmstat 1 3 | tail -1

# Output example:
# 2 0 0 2090000 230000 4410000 0 0 32 95 1250 5690 12 7 75 3 0
#
# Interpretation: cs=5690 context switches per second. High cs + high system CPU = overhead.
# Compare to baseline; 1000-5000/sec is normal, >10000/sec indicates CPU contention.


# Command 11: Check process file descriptor limits
# Usage: When you suspect a process has hit the open file limit
lsof | wc -l
# or for specific process (replace PID with actual process ID):
# lsof -p PID | wc -l
# or check system limit:
cat /proc/sys/fs/file-max

# Output example:
# lsof | wc -l
# 12345
#
# cat /proc/sys/fs/file-max
# 2097152
#
# Interpretation: 12,345 files open system-wide. Limit is 2,097,152.
# If approaching limit, increase with: sysctl -w fs.file-max=4194304


# Command 12: Monitor load average over time
# Usage: When you need to see system load trend (compare 1/5/15 minute averages)
cat /proc/loadavg
# or with history:
uptime && sleep 5 && uptime

# Output example:
# 1.23 0.98 0.87 1/256 12345
#
# Interpretation: 1.23 (1min), 0.98 (5min), 0.87 (15min) = improving load.
# If 1min > 5min > 15min, load is increasing. Compare to CPU count.
