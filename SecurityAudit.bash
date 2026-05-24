# ============================================================================
# SecurityAudit.bash - Security Auditing and Access Control Commands
# Purpose: Audit user access, file permissions, SSH, sudo usage, and failed logins
# Target: Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+, Container environments
# ============================================================================

# Command 1: List all users and their login shells
# Usage: When you need to audit user accounts and who can login
cut -d: -f1,3,6,7 /etc/passwd
# or more readable:
getent passwd | cut -d: -f1,3,5,7

# Output example:
# root:0:/root:/bin/bash
# daemon:1:/usr/sbin:/usr/sbin/nologin
# bin:2:/bin:/usr/sbin/nologin
# app:1000:/home/app:/bin/bash
# postgres:109:/var/lib/postgresql:/bin/bash
#
# Interpretation: Users root, app, postgres can login (have /bin/bash).
# daemon, bin have /nologin - they're system accounts. Check for unexpected users.


# Command 2: List all groups and their members
# Usage: When you need to see group membership and audit access control
getent group
# or specific group:
getent group sudo
# or list group members:
getent group docker

# Output example:
# root:x:0:
# sudo:x:27:user,admin
# docker:x:999:user,app
# postgres:x:109:
#
# Interpretation: sudo group has user and admin (can run sudo).
# docker group has user and app (can run docker without sudo).
# Check for unexpected privilege escalation paths.


# Command 3: Find files with world-writable permissions (security risk)
# Usage: When auditing for permission issues that could allow unauthorized access
find / -perm -002 -type f 2>/dev/null | head -20
# or find world-writable directories:
find / -perm -002 -type d 2>/dev/null

# Output example:
# /tmp/tempfile.txt
# /var/tmp/cache.dat
# /tmp
# /var/tmp
#
# Interpretation: Files in /tmp are expected to be world-writable.
# Any world-writable files outside /tmp, /var/tmp, /dev/shm are suspicious.


# Command 4: Find files with setuid bit set (potential privilege escalation)
# Usage: When looking for possible privilege escalation vectors
find / -perm -4000 -type f 2>/dev/null

# Output example:
# /usr/bin/passwd
# /usr/bin/sudo
# /usr/bin/pkexec
# /usr/bin/newgrp
#
# Interpretation: These programs run with owner's privileges.
# passwd, sudo are expected. Check for unusual setuid binaries.


# Command 5: View recent SSH login attempts and failures
# Usage: When investigating unauthorized access attempts or login issues
tail -50 /var/log/auth.log | grep sshd
# or search for failures:
grep "Failed password" /var/log/auth.log | tail -20

# Output example:
# May 24 15:45:23 server sshd[5678]: Accepted password for user from 192.168.1.50 port 54321
# May 24 15:45:22 server sshd[5679]: Failed password for invalid user admin from 192.168.1.51
# May 24 15:45:21 server sshd[5680]: Invalid user hacker from 203.0.113.100 port 56789
#
# Interpretation: Valid login from 192.168.1.50. Two failed attempts (invalid users).
# If many failed attempts, check for brute force attacks.


# Command 6: Check current SSH server configuration
# Usage: When verifying SSH security settings and authentication methods
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
# or specific settings:
grep "^PermitRootLogin\|^PasswordAuthentication" /etc/ssh/sshd_config

# Output example:
# Port 22
# Protocol 2
# PermitRootLogin no
# PasswordAuthentication yes
# PubkeyAuthentication yes
# X11Forwarding no
#
# Interpretation: SSH on port 22, root login disabled (good), password auth enabled.
# Best practice: PasswordAuthentication no (use keys only).


# Command 7: List sudo access and recent sudo commands
# Usage: When auditing who can run privileged commands and what they ran
getent group sudo
# or check recent sudo usage:
tail -20 /var/log/auth.log | grep sudo

# Output example:
# sudo:x:27:user,admin
# or:
# May 24 15:45:23 server sudo: user : TTY=pts/0 ; PWD=/home/user ; USER=root ; COMMAND=/usr/bin/docker
# May 24 15:45:20 server sudo: admin : TTY=pts/1 ; PWD=/home/admin ; USER=root ; COMMAND=/bin/systemctl restart nginx
#
# Interpretation: user and admin are in sudo group. user ran docker as root,
# admin restarted nginx. Verify these actions were authorized.


# Command 8: Check SELinux status (Red Hat/CentOS)
# Usage: When verifying mandatory access control is enabled
getenforce
# or detailed:
sestatus

# Output example:
# Enforcing
# or:
# SELinux status:                 enabled
# Current mode:                   enforcing
# Mode from config file:          enforcing
# Policy version:                 32
#
# Interpretation: SELinux is in Enforcing mode (blocks policy violations).
# If Disabled, security is reduced. Check /var/log/audit/audit.log for violations.


# Command 9: Check AppArmor status (Ubuntu/Debian)
# Usage: When verifying mandatory access control is enabled
aa-status
# or check specific profile:
aa-status | grep -i nginx

# Output example:
# apparmor module is loaded.
# 25 profiles are loaded.
# 2 processes are confined by profiles.
#
# Interpretation: AppArmor enabled with 25 profiles, 2 processes confined.
# Confined processes follow AppArmor policies.


# Command 10: Find files not owned by root or expected user
# Usage: When auditing file ownership for unauthorized modifications
find /bin /sbin /usr/bin /usr/sbin -not -user root 2>/dev/null
# or find recently modified files:
find / -mtime -1 -type f 2>/dev/null | grep -v /proc | head -20

# Output example:
# /usr/bin/app
# /usr/local/bin/custom-script
#
# Interpretation: Files /bin, /sbin should be owned by root.
# Check who owns /usr/bin/app and why. Recently modified files may indicate intrusion.


# Command 11: Check failed authentication attempts by user
# Usage: When investigating unauthorized access attempts or account lockouts
grep "authentication failure" /var/log/auth.log | tail -10
# or check for account lockouts:
grep "pam_unix.*check.*service\|account locked" /var/log/auth.log

# Output example:
# May 24 15:45:30 server sudo: pam_unix(sudo:auth): authentication failure; logname=user user=user ruser=user
# May 24 15:46:00 server sshd[5678]: [priv] fatal: Read from socket failed: Connection reset by peer
#
# Interpretation: Failed sudo authentication attempt from user account.
# Check if attacker is trying to escalate privileges.


# Command 12: Audit open network connections by root/privilege accounts
# Usage: When investigating potential backdoors or unauthorized access
netstat -tulpn | grep "LISTEN.*root"
# or using ss:
ss -tulpn | egrep "LISTEN.*sshd|LISTEN.*postgres|LISTEN.*nginx"

# Output example:
# tcp  0  0 0.0.0.0:22   0.0.0.0:*  LISTEN  1234/sshd
# tcp  0  0 127.0.0.1:5432  0.0.0.0:*  LISTEN  5678/postgres
# tcp  0  0 0.0.0.0:80   0.0.0.0:*  LISTEN  9012/nginx
#
# Interpretation: SSH on 0.0.0.0:22 (all interfaces), Postgres on localhost only (good).
# Nginx on 0.0.0.0:80. If unexpected listening ports, investigate.
