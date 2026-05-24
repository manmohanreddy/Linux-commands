# ============================================================================
# NetworkDebug.bash - Network Troubleshooting Commands
# Purpose: Debug network connectivity, DNS, ports, and traffic issues
# Target: Ubuntu 20.04+, CentOS/RHEL 8+, Debian 11+, Container environments
# ============================================================================

# Command 1: Check network interfaces and IP configuration
# Usage: When you need to see network adapter status and IP assignments
ip addr show
# or for simpler output:
ifconfig

# Output example:
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
# 2: eth0: <BROADCAST,RUNNING,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
#     inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
#
# Interpretation: eth0 is UP and has IP 172.17.0.2. If state is DOWN, network is disconnected.


# Command 2: Check active network connections and listening ports
# Usage: When you need to see what services are listening and diagnose port conflicts
netstat -tulpn | grep LISTEN
# or (modern alternative):
ss -tulpn | grep LISTEN

# Output example:
# tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1234/sshd
# tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      5678/postgres
# tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      9012/nginx
#
# Interpretation: Services listening on ports 22 (SSH), 5432 (Postgres), 80 (Nginx).
# If expected port missing, the service may not be running.


# Command 3: List all established connections
# Usage: When you need to see current network activity and who's connected to your services
netstat -tnp
# or:
ss -tnp

# Output example:
# tcp    0    0 172.17.0.2:5432    172.17.0.3:42156    ESTABLISHED 5678/postgres
# tcp    0    0 172.17.0.2:80      172.17.0.4:56789    ESTABLISHED 9012/nginx
#
# Interpretation: Postgres has 1 client connected from 172.17.0.3, Nginx has 1 client.
# High number of connections may indicate load or connection leak.


# Command 4: Check DNS resolution
# Usage: When services can't reach other hosts by name
nslookup example.com
# or preferred:
dig example.com

# Output example:
# ; <<>> DiG 9.16.1 <<>> example.com
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
# example.com.		3599	IN	A	93.184.216.34
#
# Interpretation: Successfully resolved to IP 93.184.216.34. If resolution fails,
# check /etc/resolv.conf or DNS server connectivity.


# Command 5: Test network connectivity and latency
# Usage: When you need to verify reachability and measure latency to a host
ping -c 4 8.8.8.8

# Output example:
# PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
# 64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=5.23 ms
# 64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=5.19 ms
# 64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=5.31 ms
# 64 bytes from 8.8.8.8: icmp_seq=4 ttl=119 time=5.21 ms
# --- 8.8.8.8 statistics ---
# 4 packets transmitted, 4 received, 0% packet loss, time 3008ms
#
# Interpretation: All packets received, ~5.2ms latency, 0% loss = good connectivity.
# High loss or timeout suggests network issues.


# Command 6: Trace network path to a destination
# Usage: When packets aren't reaching a host and you need to see where they're dropping
traceroute example.com
# or for ICMP-based trace:
traceroute -I example.com

# Output example:
# traceroute to example.com (93.184.216.34), 30 hops max, 60 byte packets
#  1  gateway (172.17.0.1)  0.234 ms  0.198 ms  0.187 ms
#  2  isp-router (203.0.113.1)  2.345 ms  2.301 ms  2.267 ms
#  3  transit (198.51.100.1)  12.456 ms  12.412 ms  12.378 ms
#  4  example.com (93.184.216.34)  15.234 ms  15.198 ms  15.187 ms
#
# Interpretation: Path to example.com goes through 4 hops with increasing latency.
# If a hop shows *, packets are being filtered there.


# Command 7: Check open ports with nmap (if installed)
# Usage: When you need to verify which ports are actually accessible from outside
nmap -p 1-1000 localhost
# or check specific port:
nmap -p 80,443 localhost

# Output example:
# Nmap scan report for localhost (127.0.0.1)
# Not shown: 998 closed ports
# PORT    STATE SERVICE
# 22/tcp  open  ssh
# 80/tcp  open  http
#
# Interpretation: Ports 22 (SSH) and 80 (HTTP) are open. Others are closed/filtered.


# Command 8: Check routing table
# Usage: When packets aren't being routed to the expected destination
route -n
# or:
ip route show

# Output example:
# Kernel IP routing table
# Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
# 0.0.0.0         172.17.0.1      0.0.0.0         UG    0      0        0 eth0
# 172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
# 127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
#
# Interpretation: Default gateway is 172.17.0.1, local subnet 172.17.0.0/16 is direct.
# If route missing, packets can't be delivered.


# Command 9: Monitor network traffic in real-time
# Usage: When you need to see live packet activity on an interface
tcpdump -i eth0 -n

# Output example:
# tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
# listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
# 15:23:45.123456 IP 172.17.0.2.53 > 172.17.0.3.42156: Flags [S.], seq 1234567890
# 15:23:45.234567 IP 172.17.0.3.42156 > 172.17.0.2.53: Flags [.], ack 1234567891
#
# Interpretation: Live network packets being sent/received. Filter with -i, -n, -p flags.


# Command 10: Check socket statistics and memory
# Usage: When debugging network-related memory issues or socket exhaustion
ss -s
# or for detailed info:
ss -tnpa

# Output example:
# Total: 127 (kernel 139)
# TCP:   15 (estab 3, closed 0, orphaned 0, synrecv 0, timewait 0/0), ports 0
# Transport Total     IP        IPv6
# *	      127       -         -
# RAW	      0         0         0
# UDP	      2         2         0
# TCP	      15        15        0
# INET	      17        17        0
# FRAG	      0         0         0
#
# Interpretation: 15 TCP connections, 3 established. If orphaned count is high,
# there may be connection leaks.


# Command 11: Check container network (Docker)
# Usage: When debugging container networking issues
docker network inspect bridge
# or list all networks:
docker network ls

# Output example:
# NETWORK ID     NAME      DRIVER    SCOPE
# 123abc456def   bridge    bridge    local
# 789ghi012jkl   host      host      local
# 345mno678pqr   none      null      local
#
# Interpretation: Standard Docker networks. bridge is default for containers.


# Command 12: Check Kubernetes service endpoints
# Usage: When services aren't reaching backends in Kubernetes
kubectl get endpoints
# or check specific service:
kubectl get endpoints service-name

# Output example:
# NAME            ENDPOINTS                               AGE
# kubernetes      10.0.1.1:6443                          5d
# my-service      10.244.1.10:8080,10.244.1.11:8080     2d
#
# Interpretation: my-service has 2 endpoints (pods) ready. If ENDPOINTS is empty,
# no pods matched the service selector.
