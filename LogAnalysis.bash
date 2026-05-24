# ============================================================================
# LogAnalysis.bash - Log Searching, Monitoring, and Error Detection Commands
# Purpose: Search logs, find errors, monitor real-time logs, and analyze systemd journal
# Target: Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+, Container environments
# ============================================================================

# Command 1: View recent system logs
# Usage: When you need to see recent errors or events in the system log
tail -50 /var/log/syslog
# or on RHEL/CentOS:
tail -50 /var/log/messages

# Output example:
# May 24 15:45:23 server kernel: [12345.678901] Out of memory: Kill process 5678 (java) score 845
# May 24 15:45:22 server sshd[1234]: Failed password for invalid user admin from 192.168.1.100
# May 24 15:45:20 server sudo: user : TTY=pts/0 ; PWD=/home/user ; USER=root ; COMMAND=/usr/bin/docker
#
# Interpretation: Kernel killed a Java process due to OOM, SSH login attempt failed,
# sudo command executed. Check timestamps to correlate with incidents.


# Command 2: Search logs for specific errors or keywords
# Usage: When debugging a specific issue, search logs for relevant error messages
grep -i "error" /var/log/syslog | tail -20
# or search multiple files:
grep -r "error" /var/log/*.log 2>/dev/null | tail -20

# Output example:
# /var/log/syslog:May 24 15:23:45 server app[5678]: ERROR: Database connection timeout
# /var/log/syslog:May 24 15:24:12 server app[5678]: ERROR: Failed to write to cache
# /var/log/app.log:May 24 15:24:15 ERROR [main] Connection pool exhausted
#
# Interpretation: App had database connection timeout, cache write failure.
# Check database connectivity and cache service status.


# Command 3: Monitor logs in real-time as they're written
# Usage: When you need to watch logs during an incident or deployment
tail -f /var/log/syslog
# or follow multiple files:
tail -f /var/log/syslog /var/log/app.log

# Output example:
# May 24 15:45:23 server app[5678]: INFO: Starting database migration
# May 24 15:45:25 server app[5678]: INFO: Creating table users
# May 24 15:45:27 server app[5678]: INFO: Migration complete
# (waits for new entries...)
#
# Interpretation: Live log stream. Type Ctrl+C to stop. Add -n 50 to see last 50 lines first.


# Command 4: Search for errors in a specific time range
# Usage: When you need logs around the time an incident occurred
sed -n '2026-05-24 15:20:00,2026-05-24 15:30:00p' /var/log/syslog
# or simpler, last hour:
grep "15:4[0-9]:" /var/log/syslog

# Output example:
# May 24 15:45:23 server kernel: Out of memory: Kill process
# May 24 15:45:22 server app[5678]: FATAL: Service crashed
#
# Interpretation: Two critical events between 15:40-15:50. Correlate with deployment
# or system changes around that time.


# Command 5: View systemd journal (journalctl)
# Usage: When using modern systemd, view structured logs with filtering
journalctl -n 50
# or view from specific time:
journalctl --since "2 hours ago"

# Output example:
# May 24 15:45:23 server systemd[1]: Starting nginx service...
# May 24 15:45:24 server nginx[5678]: master process started
# May 24 15:45:25 server systemd[1]: Started nginx service
#
# Interpretation: Systemd started nginx service successfully.
# journalctl is queryable and timestamped, better than text logs.


# Command 6: Find logs for a specific service using journalctl
# Usage: When debugging a specific service or application
journalctl -u nginx -n 50
# or:
journalctl -u postgresql

# Output example:
# May 24 15:45:24 server nginx[5678]: worker process started
# May 24 15:45:25 server nginx[5678]: connection from client 192.168.1.50
# May 24 15:46:00 server nginx[5678]: upstream timeout 30s
#
# Interpretation: Nginx accepting connections but upstream (backend) is timing out.
# Check backend server health.


# Command 7: Show logs with full text (not truncated)
# Usage: When default log output is cutting off important messages
journalctl -u app --output=short-full -n 20
# or for traditional logs:
cat /var/log/app.log | grep error

# Output example:
# May 24 15:45:23 server app[5678]: ERROR: Failed to connect to database at postgres-master.internal:5432
#
# Interpretation: Full message shows the exact host that connection failed.
# Use --output=json for parsing logs programmatically.


# Command 8: Count log entries by severity or keyword
# Usage: When you need to quantify error frequency
grep -c "ERROR" /var/log/syslog
# or count by hour:
grep "ERROR" /var/log/syslog | cut -d' ' -f1-2 | sort | uniq -c

# Output example:
# 127
# or:
#      45 May 24 14:
#      82 May 24 15:
#       8 May 24 16:
#
# Interpretation: 127 total ERROR entries. 82 errors in 15:00 hour is the spike.
# Investigate what changed in that hour.


# Command 9: View application-specific logs with context
# Usage: When examining application logs around an error
grep -B5 -A5 "FATAL" /var/log/app.log
# Shows 5 lines before and after match

# Output example:
# 15:44:58 app: Attempting to acquire database lock
# 15:44:59 app: Lock acquired, starting transaction
# 15:45:00 app: FATAL: Connection closed unexpectedly
# 15:45:01 app: Rolling back transaction
# 15:45:02 app: Cleanup complete, process exiting
#
# Interpretation: Transaction failed due to unexpected connection close.
# Check database server logs for concurrent activity.


# Command 10: Check log file sizes and rotation status
# Usage: When diagnosing log disk space issues or missing logs
ls -lh /var/log/*.log | sort -k5 -h
# or check all log locations:
du -sh /var/log/* | sort -h | tail -10

# Output example:
# -rw-r--r-- 1 root root 245M May 24 15:46 /var/log/syslog
# -rw-r--r-- 1 app  app  128M May 24 15:45 /var/log/app.log
# -rw-r--r-- 1 root root  45M May 24 15:40 /var/log/auth.log
#
# or:
# 256M	/var/log
# 245M	/var/log/syslog
# 128M	/var/log/app.log
#
# Interpretation: syslog at 245MB, getting large. Check logrotate config to ensure
# automatic rotation is enabled: cat /etc/logrotate.d/


# Command 11: View logs from a container using docker
# Usage: When debugging containerized applications
docker logs "container_id" --tail 50
# or stream:
docker logs -f "container_id"

# Output example:
# [10:00:00] App starting
# [10:00:05] Listening on port 8080
# [10:00:10] Database connected
#
# Interpretation: Container logs show app initialization.
# If stuck, check docker ps to verify container is still running.


# Command 12: View Kubernetes pod logs
# Usage: When debugging pods in Kubernetes
kubectl logs "pod_name" -n "namespace"
# or stream:
kubectl logs -f "pod_name"
# or from multiple pods:
kubectl logs -l app=myapp --all-containers=true

# Output example:
# 2026-05-24 15:45:23 Starting application
# 2026-05-24 15:45:25 Configuration loaded from environment
# 2026-05-24 15:45:26 Ready to accept requests
#
# Interpretation: Pod started successfully and is ready.
# If logs are old or missing, pod may have crashed. Check `kubectl describe pod`.
