# Networking Fundamentals Assignment

---

# Task 1: DNS – How Names Become IPs

## 1. What happens when you type `google.com` in a browser?

When you type `google.com`, the browser first asks a DNS server to find the website's IP address.

Using that IP address, it connects to Google's web server over the Internet.

A secure HTTPS connection is established, and the browser sends a request for the webpage.

The server responds with the website files, which the browser renders and displays.

---

## 2. DNS Record Types

| Record Type | Description |
|-------------|-------------|
| **A (Address)** | Maps a domain name to an IPv4 address. |
| **AAAA** | Maps a domain name to an IPv6 address. |
| **CNAME (Canonical Name)** | Points one domain name (alias) to another domain name. |
| **MX (Mail Exchange)** | Specifies the mail server responsible for receiving emails for a domain. |
| **NS (Name Server)** | Identifies the authoritative DNS servers for a domain. |

---

## 3. Run `dig google.com` — Identify the A Record and TTL

### Command

```bash
dig google.com
```

### Output

```text
root@ubuntu-host ~ ➜  dig google.com

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31430
;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 4458c35df5a876aa (echoed)

;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             30      IN      A       173.194.222.102
google.com.             30      IN      A       173.194.222.138
google.com.             30      IN      A       173.194.222.113
google.com.             30      IN      A       173.194.222.101
google.com.             30      IN      A       173.194.222.100
google.com.             30      IN      A       173.194.222.139

;; Query time: 1 msec
;; SERVER: 10.96.0.10#53(10.96.0.10) (UDP)
;; WHEN: Wed Jul 15 14:25:16 UTC 2026
;; MSG SIZE  rcvd: 207
```

### A Records

- `173.194.222.102`
- `173.194.222.138`
- `173.194.222.113`
- `173.194.222.101`
- `173.194.222.100`
- `173.194.222.139`

### TTL

**30 seconds**

---

# Task 2: IP Addressing

## 1. What is an IPv4 address? How is it structured?

An IPv4 address is a unique **32-bit numerical identifier** assigned to a device on a network, allowing it to communicate over the Internet or a local network.

### Structure

- Consists of **4 octets (8 bits each)** separated by dots.
- Each octet ranges from **0–255**.
- Example:

```text
192.168.1.10
```

```
192 | 168 | 1 | 10
```

---

## 2. Difference Between Public and Private IP Addresses

| Public IP | Private IP |
|-----------|------------|
| Used to identify a device on the Internet. | Used within a local network (LAN). |
| Assigned by an ISP. | Assigned by a router or network administrator. |
| Routable over the Internet. | Not routable over the Internet. |
| Example: `8.8.8.8` | Example: `192.168.1.10` |

---

## 3. What are the Private IP Ranges?

The private IPv4 address ranges are:

- **10.0.0.0 – 10.255.255.255** (`10.0.0.0/8`)
- **172.16.0.0 – 172.31.255.255** (`172.16.0.0/12`)
- **192.168.0.0 – 192.168.255.255** (`192.168.0.0/16`)

These address ranges are reserved for private networks and are **not routable on the public Internet**.

---

## 4. Run `ip addr show` — Identify the Private IP

### Command

```bash
ip addr show
```

### Output

```text
root@ubuntu-host ~ ➜  ip addr show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host

3: eth0@if2038: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default qlen 1000
    link/ether ae:84:7b:87:83:b6 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.51.114/32 scope global eth0
    inet6 fe80::ac84:7bff:fe87:83b6/64 scope link
```

### Private IP Address

**10.244.51.114/32** on the **eth0** interface.

---

# Task 3: CIDR & Subnetting

## 1. What does `/24` mean in `192.168.1.0/24`?

The `/24` is the **CIDR prefix**.

It means:

- First **24 bits** represent the **network**.
- Remaining **8 bits** represent the **host**.

| Property | Value |
|----------|-------|
| Network Address | `192.168.1.0` |
| Subnet Mask | `255.255.255.0` |
| Host Range | `192.168.1.1 – 192.168.1.254` |
| Broadcast Address | `192.168.1.255` |
| Usable Hosts | **254** |

---

## 2. How Many Usable Hosts?

| CIDR | Usable Hosts |
|------|--------------|
| `/24` | **254** |
| `/16` | **65,534** |
| `/28` | **14** |

---

## 3. Why Do We Subnet?

Subnetting divides a large network into smaller, manageable networks.

Benefits include:

- Efficient use of IP addresses.
- Easier network management and troubleshooting.
- Improved performance by reducing broadcast traffic.

---

## 4. CIDR Table

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|------|-------------|-----------|--------------|
| `/24` | `255.255.255.0` | 256 | 254 |
| `/16` | `255.255.0.0` | 65,536 | 65,534 |
| `/28` | `255.255.255.240` | 16 | 14 |

---

# Task 4: Ports – The Doors to Services

## 1. What is a Port? Why Do We Need It?

A port is a logical number used by a device to identify a specific application or service running on a network.

Ports allow multiple applications to use the same IP address while keeping their network traffic separate.

They also help the operating system determine which application should receive incoming data.

---

## 2. Common Ports

| Port | Service |
|------|---------|
| 22 | SSH |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |
| 6379 | Redis |
| 27017 | MongoDB |

---

## Verify Running Services

### Check SSH

```bash
ss -tulpn | grep 22
```

Output:

```text
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=976,fd=3))
tcp LISTEN 0 128 [::]:22 [::]:* users:(("sshd",pid=976,fd=4))
```

---

### Check DNS

```bash
ss -tulpn | grep 53
```

Output:

```text
udp UNCONN 0 0 127.0.0.53%lo:53 0.0.0.0:* users:(("systemd-resolve",pid=458,fd=13))
tcp LISTEN 0 4096 127.0.0.53%lo:53 0.0.0.0:* users:(("systemd-resolve",pid=458,fd=14))
```

---

# Task 5: Putting It Together

## 1. You run:

```bash
curl http://myapp.com:8080
```

### What networking concepts are involved?

1. **DNS** – `myapp.com` is resolved to an IP address.
2. **IP Addressing** – The client connects to the resolved IP.
3. **Port Numbers** – Port **8080** identifies the application.
4. **TCP Connection** – A TCP connection is established.
5. **HTTP Protocol** – `curl` sends an HTTP request and receives a response.
6. **Routing** – Network devices forward packets between client and server.

---

## 2. Your app can't reach a database at `10.0.1.50:3306` — What would you check first?

### 1. Network Connectivity

Verify the application server can reach the database.

```bash
ping 10.0.1.50
```

or

```bash
traceroute 10.0.1.50
```

---

### 2. Port Availability

Check whether MySQL is listening on port **3306**.

```bash
nc -vz 10.0.1.50 3306
```

---

### 3. Database Service

Ensure the MySQL service is running and accepting connections.

---

### 4. Firewall or Security Rules

Check:

- Host firewall
- Security groups
- Network ACLs

Ensure port **3306** is allowed.

---

### 5. Database Configuration

Verify:

- `bind-address`
- MySQL user permissions
- Allowed client hosts

---
