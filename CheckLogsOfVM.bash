# check the logs of a Linux VM

journalctl

# Display logs from the last N hours:
journalctl --since "N hours ago"

# Display logs from a specific time range:
journalctl --since "YYYY-MM-DD HH:MM:SS" --until "YYYY-MM-DD HH:MM:SS"

# Display logs for a specific service:
journalctl -u <service_name>

# Display logs with a specific priority level:
journalctl -p <priority_level>

# Display logs in real-time:
journalctl -f

# if you want to search for the string "error" in the syslog file, you can use the following command:
grep "error" /var/log/syslog

# if you want to search for lines that contain either "error" or "warning", you can use the following command:
grep -E "error|warning" /var/log/syslog
