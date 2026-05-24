# Linux Commands for SRE & DevOps

A curated collection of Linux debugging commands organized by category. Perfect for on-call engineers diagnosing production issues on modern Linux distributions (Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+) and containerized environments.

## Quick Start

Choose a script based on what you're debugging:

| **Category** | **Use When** | **Script** |
|---|---|---|
| Network connectivity issues | Services can't reach each other, DNS failures, port problems | [`NetworkDebug.bash`](#networkdebug) |
| Performance problems | High CPU, memory usage, slow disk I/O, load spikes | [`PerformanceAnalysis.bash`](#performanceanalysis) |
| Errors in logs | Can't find errors, need to monitor real-time logs, analyze patterns | [`LogAnalysis.bash`](#loganalysis) |
| Container/service issues | Pod crashed, service won't start, systemd issues | [`ContainerSystemdDebug.bash`](#containersystemddebug) |
| Security audit | Unauthorized access, permission issues, login failures | [`SecurityAudit.bash`](#securityaudit) |

## Scripts

### NetworkDebug.bash

**12 commands for network troubleshooting**

Covers:
- Interface and IP configuration
- Open ports and listening services
- DNS resolution
- Connectivity testing (ping, traceroute)
- Established connections and socket stats
- Docker and Kubernetes networking

**Usage:**
```bash
bash NetworkDebug.bash
```

Then copy/paste relevant commands. Each includes usage guidance and sample output.

### PerformanceAnalysis.bash

**12 commands for CPU, memory, and I/O performance**

Covers:
- System load and CPU usage
- Memory utilization by process
- Disk space and file system usage
- Disk I/O performance (iostat)
- Memory paging and swap activity
- Process monitoring (top, ps)
- Context switching overhead
- File descriptor limits

**Usage:**
```bash
bash PerformanceAnalysis.bash
```

Run individual commands to diagnose performance bottlenecks. Compare CPU/memory/I/O metrics to identify the limiting resource.

### LogAnalysis.bash

**12 commands for log searching and monitoring**

Covers:
- System log viewing and searching
- Error pattern detection
- Real-time log monitoring
- Systemd journal inspection
- Time-range based searches
- Log rotation and file size
- Container and Kubernetes logs

**Usage:**
```bash
bash LogAnalysis.bash
```

Use grep patterns to find errors, tail -f to monitor live logs during incidents, journalctl for structured logs.

### ContainerSystemdDebug.bash

**12 commands for containers and systemd services**

Covers:
- Docker container status and logs
- Container resource usage and inspection
- systemd service status and logs
- Systemd dependencies and startup order
- Kubernetes pod status and debugging
- Cgroup memory and CPU limits

**Usage:**
```bash
bash ContainerSystemdDebug.bash
```

Use docker ps/inspect for container issues, systemctl for service status, kubectl for Kubernetes pods.

### SecurityAudit.bash

**12 commands for security and access auditing**

Covers:
- User and group management
- File permissions and ownership
- SSH access logs and configuration
- Sudo usage and privilege escalation
- SELinux and AppArmor status
- Failed authentication attempts
- Unexpected network listening ports

**Usage:**
```bash
bash SecurityAudit.bash
```

Run regularly to audit user access, check for unauthorized privilege escalation paths, monitor failed logins.

## Common Debugging Workflows

### "The service is down"

1. **Check if running:** `ContainerSystemdDebug.bash` → `systemctl status <service>` or `docker ps`
2. **See why it failed:** `LogAnalysis.bash` → `journalctl -u <service>` or `docker logs <container>`
3. **Fix and restart:** `systemctl restart <service>` or `docker restart <container>`
4. **Verify it's up:** Rerun status command

### "High CPU usage"

1. **Find CPU hog:** `PerformanceAnalysis.bash` → `ps aux --sort=-%cpu`
2. **Monitor it:** `top -p <PID>` to watch in real-time
3. **Check what it's doing:** `LogAnalysis.bash` → logs for that process
4. **Examine threads:** `ps -eLf | grep <PID>`

### "Out of disk space"

1. **See used space:** `PerformanceAnalysis.bash` → `df -h`
2. **Find large files:** `PerformanceAnalysis.bash` → `du -sh /*`
3. **Check logs:** Often `/var/log` is culprit
4. **Cleanup:** `rm` old logs or `logrotate` to archive

### "Can't connect to service"

1. **Check service listening:** `NetworkDebug.bash` → `netstat -tulpn | grep port`
2. **Check connectivity:** `NetworkDebug.bash` → `ping`, `traceroute`
3. **Check DNS:** `NetworkDebug.bash` → `dig/nslookup`
4. **Check service logs:** `LogAnalysis.bash` → logs may show why it's not accepting connections

## Requirements

- Modern Linux (Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+)
- Common tools: bash, grep, tail, ss/netstat, top, journalctl
- Optional: docker (for container debugging), kubectl (for Kubernetes)
- Root or sudo access for some commands (file permissions, journal, systemd)

## Format

Each script contains commands organized as:

```bash
# Command N: Short title
# Usage: When you'd use this command
<command>

# Output example:
# <realistic sample output>

# Interpretation: What the output means and how to diagnose issues
```

Copy the command that matches your scenario and run it. Sample output helps you recognize what success looks like.

## Contributing

Add more commands by:
1. Opening a pull request with the new command(s)
2. Following the format above (what, when, output example, interpretation)
3. Testing on modern Linux + container environments
4. Ensuring commands are read-only or safe (no destructive operations)

## License

Open source - use freely for production debugging
