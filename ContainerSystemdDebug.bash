# ============================================================================
# ContainerSystemdDebug.bash - Container and Systemd Service Troubleshooting
# Purpose: Debug Docker containers, Kubernetes pods, and systemd services
# Target: Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+, Container environments
# ============================================================================

# Command 1: List running containers
# Usage: When you need to see what containers are running and their status
docker ps
# or with more details:
docker ps -a

# Output example:
# CONTAINER ID   IMAGE                 COMMAND                  CREATED       STATUS              NAMES
# 5a6b7c8d9e0f   myapp:latest          "python app.py"          2 days ago    Up 2 days           myapp-prod
# 2f3g4h5i6j7k   postgres:13           "postgres"               2 days ago    Up 2 days           db-master
# 8x9y0z1a2b3c   nginx:latest          "nginx -g daemon off"    3 days ago    Exited (0) 5 days   nginx-test
#
# Interpretation: myapp and db-master are UP. nginx-test exited 5 days ago.
# Check exited containers for crashes.


# Command 2: Inspect container configuration and environment
# Usage: When you need to see container's IP, mounts, environment variables
docker inspect <container_id>
# or just IP:
docker inspect -f '{{.NetworkSettings.IPAddress}}' <container_id>

# Output example:
# {
#   "Id": "5a6b7c8d9e0f...",
#   "Created": "2026-05-22T10:00:00.000Z",
#   "State": {
#     "Status": "running",
#     "Pid": 5678
#   },
#   "NetworkSettings": {
#     "IPAddress": "172.17.0.2"
#   }
# }
#
# Interpretation: Container IP is 172.17.0.2, PID is 5678 (use for strace).
# Check mounts for volume issues, environment for config.


# Command 3: View container logs
# Usage: When you need to see container stdout/stderr for debugging
docker logs <container_id>
# or stream:
docker logs -f <container_id>

# Output example:
# [2026-05-24 10:00:00] Application starting
# [2026-05-24 10:00:05] Listening on 0.0.0.0:8080
# [2026-05-24 10:00:10] Database connection established
#
# Interpretation: Container app started successfully. Add -f to watch real-time.
# If logs are old, container may have crashed.


# Command 4: Check container resource usage
# Usage: When you need to see CPU, memory, and I/O usage of a container
docker stats <container_id>
# or all containers:
docker stats

# Output example:
# CONTAINER ID   NAME              CPU %     MEM USAGE / LIMIT     MEM %
# 5a6b7c8d9e0f   myapp-prod        45.23%    512 MiB / 2 GiB      25%
# 2f3g4h5i6j7k   db-master         12.45%    1.2 GiB / 4 GiB      30%
#
# Interpretation: myapp using 45% CPU and 512MB RAM (25% of 2GB limit).
# db-master at 30% memory limit. Watch for approaching limits.


# Command 5: Execute command inside a running container
# Usage: When you need to debug inside a container or verify configuration
docker exec -it <container_id> /bin/bash
# or specific command:
docker exec <container_id> ps aux

# Output example:
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.1  0.5  20000  5000 ?       S    10:00   0:05 python app.py
# root       234  0.0  0.2  10000  2000 ?       S    10:00   0:01 postgres
#
# Interpretation: Process tree inside container. Confirm expected processes are running.


# Command 6: View Docker images and their sizes
# Usage: When managing Docker images or debugging build issues
docker images
# or with details:
docker images --digests

# Output example:
# REPOSITORY        TAG       IMAGE ID       CREATED       SIZE
# myapp            latest    a1b2c3d4e5f6   2 days ago    512MB
# myapp            v1.0      f6e5d4c3b2a1   3 weeks ago   520MB
# postgres         13        9z8y7x6w5v4u   2 months ago  314MB
#
# Interpretation: Two versions of myapp (512MB and 520MB).
# Clean up old images with: docker rmi <image_id>


# Command 7: Check container network connectivity
# Usage: When containers can't reach each other or external services
docker network inspect bridge
# or list networks:
docker network ls

# Output example:
# NETWORK ID     NAME      DRIVER    SCOPE
# 123abc456def   bridge    bridge    local
# 789ghi012jkl   host      host      local
# containers in bridge network:
# 5a6b7c8d9e0f   myapp-prod   172.17.0.2
# 2f3g4h5i6j7k   db-master    172.17.0.3
#
# Interpretation: Containers on bridge network can reach each other via IP.
# Use container name (db-master) as hostname if linked.


# Command 8: Check systemd service status
# Usage: When you need to see if a service is running and recent activity
systemctl status nginx
# or:
systemctl is-active postgres

# Output example:
# ● nginx.service - The NGINX HTTP and reverse proxy server
#      Loaded: loaded (/etc/systemd/system/nginx.service; enabled; vendor preset: enabled)
#      Active: active (running) since Wed 2026-05-22 10:00:00 UTC; 2 days ago
#      Main PID: 5678 (nginx)
#      Tasks: 5 (limit: 2048)
#      CPU: 2h 34m 12s
#      CGroup: /system.slice/nginx.service
#
# Interpretation: nginx is active and has been running 2 days.
# CPU time 2h 34m is reasonable. Check logs if issues.


# Command 9: View systemd service logs
# Usage: When debugging a systemd service or checking startup messages
journalctl -u nginx -n 50
# or with errors only:
journalctl -u nginx -p err -n 50

# Output example:
# May 22 10:00:00 server systemd[1]: Starting nginx service...
# May 22 10:00:01 server nginx[5678]: master process started
# May 22 10:00:02 server systemd[1]: Started nginx service
#
# Interpretation: Service started successfully. If errors, check -p err output.


# Command 10: Check systemd service dependencies and ordering
# Usage: When investigating why a service didn't start or startup order
systemctl list-dependencies <service>
# or show startup sequence:
systemctl list-jobs

# Output example:
# nginx.service
# └─ network-online.target
#    └─ network.target
#
# Interpretation: nginx depends on network being online.
# If network.target fails, nginx won't start.


# Command 11: Check container/pod cgroup memory and CPU limits
# Usage: When debugging resource limit issues or OOM kills
cat /sys/fs/cgroup/memory/docker/<container_id>/memory.limit_in_bytes
# or for CPU:
cat /sys/fs/cgroup/cpu/docker/<container_id>/cpu.cfs_quota_us

# Output example:
# 2147483648
# (2GB in bytes)
#
# Interpretation: Container memory limit is 2GB. If process uses more, OOM killer activates.


# Command 12: Check Kubernetes pod status and conditions
# Usage: When debugging Kubernetes pod issues
kubectl get pods -n <namespace>
# or detailed:
kubectl describe pod <pod_name> -n <namespace>

# Output example:
# NAME              READY   STATUS    RESTARTS   AGE
# myapp-5d8c7f9b    1/1     Running   0          2d
# myapp-5d8c7f9c    0/1     CrashLoop 12         1h
#
# Detailed:
# Status: Running / Pending / CrashLoopBackOff / ImagePullBackOff
# Conditions:
#   Ready: True
#   ContainersReady: True
#
# Interpretation: One pod running, one in CrashLoopBackOff (restarting every 5s).
# Check logs of crashing pod: kubectl logs <pod_name>
