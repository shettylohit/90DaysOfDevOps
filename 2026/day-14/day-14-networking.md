The easiest way to understand the OSI model is to follow **one real example**.

### Scenario

A **laptop** wants to open a website hosted on a **server**.

```
Laptop  ---------------------- Internet ----------------------  Server
(Client)                                                   (Website)
```

Suppose you type:

**[https://www.example.com](https://www.example.com)**

Now let's see what happens at **each OSI layer**.

---

# Step 1: Application Layer (Layer 7)

### What happens?

You type a website URL in your browser and press **Enter**.

The browser creates an **HTTP/HTTPS request**.

Example request:

```
GET /index.html HTTP/1.1
Host: www.example.com
```

Think of this layer as **you writing a letter**.

**Laptop:**

> "Server, please send me your homepage."

---

# Step 2: Presentation Layer (Layer 6)

Before sending the request:

* Encrypt the data (HTTPS uses TLS)
* Compress it if needed
* Convert data into a standard format

Now the message looks like encrypted data.

Imagine putting your letter inside a **locked box** so no one can read it.

---

# Step 3: Session Layer (Layer 5)

A communication session is created.

Think of this as making a phone call.

```
Laptop:
"Hello Server,
Can we communicate?"
```

Server replies:

```
Yes.
Session started.
```

Now both know they're talking to each other.

---

# Step 4: Transport Layer (Layer 4)

Suppose the webpage is **5 MB**.

Sending all 5 MB at once isn't practical.

The Transport layer splits it into many small pieces.

Example:

```
Piece 1
Piece 2
Piece 3
Piece 4
...
Piece 500
```

Each piece gets:

* Sequence number
* Port number
* Error-checking information

Example:

```
Segment 1
Port: 443
Sequence: 1

Segment 2
Port: 443
Sequence: 2
```

If Segment 50 is lost, TCP requests only Segment 50 again instead of the entire webpage.

This layer is like numbering every page of a book before mailing it.

---

# Step 5: Network Layer (Layer 3)

Now the laptop needs to find the server on the internet.

Example:

```
Laptop IP:
192.168.1.5

Server IP:
93.184.216.34
```

The Network layer adds:

```
Source IP:
192.168.1.5

Destination IP:
93.184.216.34
```

Routers use these IP addresses to decide where the packet should go.

Think of this as writing the destination city and country on a package.

---

# Step 6: Data Link Layer (Layer 2)

The packet now needs to travel to the **next device** on the local network (usually your Wi-Fi router).

The Data Link layer adds MAC addresses.

Example:

```
Source MAC:
AA:BB:CC:11:22:33

Destination MAC:
11:22:33:44:55:66
```

MAC addresses work only on the local network.

If the packet passes through another router, the MAC addresses change, but the IP addresses remain the same.

Think of MAC addresses as the house numbers used for the next local delivery.

---

# Step 7: Physical Layer (Layer 1)

Everything is finally converted into bits.

```
010101010101011000101001...
```

These bits travel through:

* Wi-Fi radio waves
* Ethernet cable
* Fiber-optic cable

This is simply the transmission of electrical, optical, or radio signals.

---

# Journey Across the Internet

```
Laptop
   │
Wi-Fi
   │
Router
   │
ISP
   │
Many Routers
   │
Data Center
   │
Server
```

Every router checks the destination IP and forwards the packet closer to the server.

---

# What Happens at the Server?

The server receives the bits and works upward through the OSI layers.

### Layer 1

Receives bits:

```
010100101...
```

↓

### Layer 2

Removes the frame.

↓

### Layer 3

Reads the destination IP.

```
Destination:
93.184.216.34

That's my IP.
```

↓

### Layer 4

Reassembles the segments.

```
1
2
3
4
5
```

↓

### Layer 5

Checks the communication session.

↓

### Layer 6

Decrypts the HTTPS data.

↓

### Layer 7

The web server reads the request:

```
GET /index.html
```

It finds the requested webpage.

---

# Server Sends the Response

The server now replies:

```
HTTP/1.1 200 OK

<html>
Welcome!
</html>
```

The response goes back through exactly the same seven layers:

```
Application
↓

Presentation
↓

Session
↓

Transport
↓

Network
↓

Data Link
↓

Physical
```

It travels across the internet back to your laptop.

Your laptop then performs the reverse process (decapsulation), and your browser displays the webpage.

---

# Visual Flow

```
               LAPTOP

Application
   "I need the webpage."
        │
Presentation
   Encrypt
        │
Session
   Open communication
        │
Transport
   Split into segments
        │
Network
   Add IP addresses
        │
Data Link
   Add MAC addresses
        │
Physical
   Convert to bits
        │
══════════ INTERNET ══════════
        │
Physical
        │
Data Link
        │
Network
        │
Transport
        │
Session
        │
Presentation
        │
Application
   SERVER reads request
```

### A simple analogy: Sending a courier package

* **Application:** You write the letter (the message).
* **Presentation:** You lock or encode it (encryption/compression).
* **Session:** You establish contact with the recipient.
* **Transport:** You split a large package into numbered boxes.
* **Network:** You write the destination city and postal address (IP address).
* **Data Link:** The local courier labels each box for the next delivery stop (MAC address).
* **Physical:** Trucks, planes, or roads carry the boxes (bits over cables or Wi-Fi).

At the destination, the process happens in reverse: the courier delivers the boxes, the labels are removed, the boxes are reassembled, the lock is opened, and the recipient reads the original message. This is exactly how a server and a laptop exchange data using the OSI model.



The **TCP/IP model** is the practical networking model used on the Internet. Unlike the OSI model (7 layers), the TCP/IP model has **4 layers**.






## TCP/IP Model Layers

| Layer                 | Equivalent OSI Layers | Main Job                               |
| --------------------- | --------------------- | -------------------------------------- |
| Application           | OSI Layers 5, 6, 7    | User applications and network services |
| Transport             | OSI Layer 4           | Reliable or fast data delivery         |
| Internet              | OSI Layer 3           | Routing using IP addresses             |
| Network Access (Link) | OSI Layers 1 & 2      | Sending data over the local network    |

Let's use the **same example**.

### Scenario

Your **laptop** wants to open a webpage from a **server**.

```text
Laptop  ---------------- Internet ----------------  Server
(Client)                                      (Website)
```

You type:

```text
https://www.example.com
```

Now let's follow the data through the TCP/IP model.

---

# Layer 4 – Application Layer

This is where your application (browser) creates the request.

You type:

```text
https://www.example.com
```

Your browser creates:

```text
GET / HTTP/1.1
Host: www.example.com
```

If you're using HTTPS, this layer also works with TLS to establish a secure connection.

Think of it as writing a letter:

```text
Laptop:

"Hello Server,
Please send me your homepage."
```

The message is ready to send.

---

# Layer 3 – Transport Layer

The Transport layer decides **how** the message should be delivered.

For websites, it usually uses **TCP**.

TCP first establishes a connection using the **Three-Way Handshake**.

## Step 1

Laptop sends

```text
SYN
```

Meaning:

> "Server, I'd like to communicate."

---

## Step 2

Server replies

```text
SYN + ACK
```

Meaning:

> "I received your request.
> I'm ready."

---

## Step 3

Laptop sends

```text
ACK
```

Meaning:

> "Great.
> Let's start."

Connection established.

```text
Laptop                Server

SYN -------------------->

     <---------------- SYN + ACK

ACK -------------------->
```

Now TCP starts sending data.

---

Suppose the webpage is **8 MB**.

TCP divides it into many small segments.

Example

```text
Segment 1

Segment 2

Segment 3

...

Segment 800
```

Each segment gets

* Sequence Number
* Source Port
* Destination Port
* Checksum

Example

```text
Source Port:
51520

Destination Port:
443

Sequence:
25
```

If Segment 25 is lost,

The server sends

```text
Please resend Segment 25.
```

Only that segment is retransmitted.

Think of this layer as numbering every page of a book before mailing it.

---

# Layer 2 – Internet Layer

Now TCP hands the segments to the Internet layer.

The Internet layer uses **IP**.

It adds:

```text
Source IP:
192.168.1.10

Destination IP:
93.184.216.34
```

Now every packet knows

* Who sent it
* Where it should go

Routers use these IP addresses to forward packets.

Imagine writing the destination city and postal address on a parcel.

---

# Journey Across the Internet

```text
Laptop
   │
Wi-Fi
   │
Home Router
   │
ISP
   │
Router
   │
Router
   │
Router
   │
Data Center
   │
Server
```

Each router looks only at the destination IP and forwards the packet toward the server.

---

# Layer 1 – Network Access Layer

The packet has reached your local network.

The Network Access layer prepares it for physical transmission.

It adds:

```text
Source MAC

AA:BB:CC:11:22:33

Destination MAC

11:22:33:44:55:66
```

Then it converts everything into bits.

```text
010101010100010101...
```

These bits travel through

* Wi-Fi
* Ethernet cable
* Fiber-optic cable

This is the actual transmission of data.

---

# What Happens at the Server?

The server receives the bits.

Now it processes the data in reverse.

---

## Network Access Layer

Receives

```text
010101001011...
```

Removes

* MAC Address
* Frame

---

## Internet Layer

Reads the IP address.

```text
Destination IP

93.184.216.34

This is my IP.
```

Packet accepted.

---

## Transport Layer

TCP receives all segments.

```text
1

2

3

4

5
```

It checks:

* Sequence numbers
* Missing segments
* Errors

If everything is correct, TCP reassembles the original message.

---

## Application Layer

The web server reads

```text
GET /
```

It processes the request and finds the webpage.

Then it creates the response:

```text
HTTP/1.1 200 OK

<html>

Welcome

</html>
```

The response travels back through the same four layers in reverse order.

---

# Complete Flow

```text
                 LAPTOP

Application
Browser creates HTTP request
        │
Transport
TCP handshake
TCP segments
Port numbers
        │
Internet
Adds IP addresses
Routing
        │
Network Access
Adds MAC addresses
Converts to bits
        │
══════════ INTERNET ══════════
        │
Network Access
Receives bits
        │
Internet
Checks IP address
        │
Transport
Reassembles TCP segments
        │
Application
Server reads request
Creates response
```

---

# OSI vs TCP/IP Mapping

| OSI Model    | TCP/IP Model   |
| ------------ | -------------- |
| Application  | Application    |
| Presentation | Application    |
| Session      | Application    |
| Transport    | Transport      |
| Network      | Internet       |
| Data Link    | Network Access |
| Physical     | Network Access |

---

# Real-Life Analogy: Sending a Courier Package

Imagine you're sending an important document to a friend.

* **Application Layer:** You write the letter and place it in an envelope.
* **Transport Layer:** If the document is too large, you split it into multiple numbered envelopes so they can be reassembled in the correct order.
* **Internet Layer:** You write the sender's and receiver's postal addresses on each envelope so the postal system knows where to deliver them.
* **Network Access Layer:** The local post office collects the envelopes and physically transports them by truck, train, airplane, or ship.

At the destination, the process happens in reverse:

1. The local post office delivers the envelopes.
2. The address is checked.
3. All numbered envelopes are gathered and arranged in order.
4. The recipient opens the envelope and reads the original letter.

This is exactly how the **TCP/IP model** works when your laptop communicates with a server over the Internet. The TCP/IP model is the foundation of modern networking and is the protocol suite used by virtually all internet communication today.


````markdown
# Linux Networking Commands Cheat Sheet

This guide covers commonly used Linux networking commands for identifying network information, testing connectivity, troubleshooting routes, checking open ports, performing DNS lookups, testing HTTP connectivity, and viewing network connections.

---

# 1. Identity Commands

## `hostname -I`

Displays only the IP address(es) assigned to your system.

```bash
hostname -I
```

Example:

```text
root@ubuntu-host ~ ➜ hostname -I
10.244.223.61
```

### Purpose

- Displays all assigned IPv4/IPv6 addresses.
- Outputs only the IP addresses separated by spaces.

---

## `ip addr show`

Displays detailed information about all network interfaces.

```bash
ip addr show
```

Example:

```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo

3: eth0@if9908: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450
    inet 10.244.223.61/32 scope global eth0
    inet6 fe80::9429:26ff:fe3e:dd7/64 scope link
```

### Information Displayed

- Interface name (`eth0`, `lo`)
- MAC address
- IPv4 address
- IPv6 address
- MTU
- Interface status (UP/DOWN)

---

# 2. Reachability Commands

## `ping`

The `ping` command checks whether a remote host is reachable and measures the round-trip time (RTT) between your system and the destination.

```bash
ping -c 4 google.com
```

Example:

```text
PING google.com (142.251.38.78) 56(84) bytes of data.
64 bytes from tzhema-ad-in-f14.1e100.net (142.251.38.78): icmp_seq=1 ttl=112 time=2.62 ms
64 bytes from tzhema-ad-in-f14.1e100.net (142.251.38.78): icmp_seq=2 ttl=112 time=2.14 ms
64 bytes from tzhema-ad-in-f14.1e100.net (142.251.38.78): icmp_seq=3 ttl=112 time=2.69 ms
64 bytes from tzhema-ad-in-f14.1e100.net (142.251.38.78): icmp_seq=4 ttl=112 time=1.83 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 1.826/2.318/2.694/0.355 ms
```

### Output Explanation

- **64 bytes** – Size of the reply packet.
- **icmp_seq** – Sequence number of each ICMP request.
- **ttl** – Time To Live; decremented by each router the packet traverses.
- **time** – Round-trip latency in milliseconds.
- **packet loss** – Percentage of packets that failed to return.

---

# 3. Path Discovery Commands

Both `traceroute` and `tracepath` display the path packets take to reach a destination by showing each intermediate router (hop).

---

## `traceroute`

Displays the route packets take through the network.

```bash
traceroute times.com
```

Example:

```text
traceroute to times.com (151.101.193.164), 30 hops max

1  static.36.114.42.77.clients.your-server.de
2  10.0.1.1
3  10.0.15.7
4  172.31.1.1
5  static.116.117.108.65.clients.your-server.de
6  * * *
8  core-spine-rdev1.cloud1.hel1.hetzner.com
9  core32.hel1.hetzner.com
...
```

### Output Explanation

Each hop displays:

- Hop number
- Hostname
- IP address
- Three RTT (Round-Trip Time) measurements

Asterisks (`*`) indicate that a router did not respond within the timeout period.

---

## `tracepath`

`tracepath` performs a similar function as `traceroute` but does **not** require root privileges.

```bash
tracepath times.com
```

Example:

```text
1?: [LOCALHOST] pmtu 1450
1: static.36.114.42.77.clients.your-server.de
2: 10.0.1.1
3: 10.0.15.7
4: 172.31.1.1
5: static.116.117.108.65.clients.your-server.de
6: no reply
8: core-spine-rdev1.cloud1.hel1.hetzner.com
9: core32.hel1.hetzner.com
...
Resume: pmtu 1450
```

### Output Explanation

Each line represents one network hop.

Information shown includes:

- Hop number
- Hostname/IP address
- RTT (Round-Trip Time)
- PMTU (Path Maximum Transmission Unit)

Unlike `traceroute`, `tracepath` uses standard UDP packets and does not require superuser privileges.

---

# 4. Check Open Ports

## `ss -tunlp`

Displays listening ports and active network connections.

```bash
ss -tunlp
```

Example:

```text
Netid State  Local Address:Port   Process

udp   UNCONN 127.0.0.53:53        systemd-resolve
tcp   LISTEN 0.0.0.0:22           sshd
tcp   LISTEN 127.0.0.53:53        systemd-resolve
tcp   LISTEN 0.0.0.0:8080         ttyd
```

### Option Breakdown

| Option | Meaning |
|---------|---------|
| `-t` | TCP sockets |
| `-u` | UDP sockets |
| `-n` | Show numeric addresses |
| `-l` | Show listening sockets |
| `-p` | Show process information |

---

# 5. DNS Name Resolution

Two commonly used DNS lookup tools are:

- `dig`
- `nslookup`

---

## `dig`

Provides detailed DNS information.

```bash
dig google.com
```

Example:

```text
;; QUESTION SECTION:
google.com. IN A

;; ANSWER SECTION:
google.com. 30 IN A 192.178.25.78
```

Information includes:

- Query type
- DNS server used
- TTL
- DNS response
- Query time

`dig` is the preferred tool for DNS troubleshooting because it provides comprehensive information.

---

## `nslookup`

Performs quick DNS lookups.

```bash
nslookup google.com
```

Example:

```text
Server: 10.96.0.10

Non-authoritative answer:

google.com
Address: 173.194.222.102
Address: 173.194.222.113
Address: 173.194.222.139
Address: 2a00:1450:4026:800::200e
```

### Comparison

| Tool | Best Use |
|------|----------|
| `nslookup` | Quick DNS lookups |
| `dig` | DNS troubleshooting and analysis |

---

# 6. HTTP Connectivity Check

## `curl`

The `curl` command transfers data to or from a server.

Example:

```bash
curl google.com
```

Output:

```html
<HTML>
<HEAD>
<TITLE>301 Moved</TITLE>
</HEAD>
<BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY>
</HTML>
```

---

## `curl -I`

The `-I` option requests only the HTTP response headers.

```bash
curl -I google.com
```

Example:

```text
HTTP/1.1 301 Moved Permanently
Location: http://www.google.com/
Content-Type: text/html
Server: gws
Content-Length: 219
```

### Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 301 | Moved Permanently |
| 302 | Temporary Redirect |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

# 7. View Network Connections

## `netstat -an | head`

Displays the first few active network connections.

```bash
netstat -an | head -10
```

Example:

```text
Active Internet connections

Proto Recv-Q Send-Q Local Address Foreign Address State

tcp 0 0 0.0.0.0:22 0.0.0.0:* LISTEN
tcp 0 0 127.0.0.53:53 0.0.0.0:* LISTEN
tcp 0 0 0.0.0.0:8080 0.0.0.0:* LISTEN
tcp 0 0 10.244.223.61:8080 10.244.51.137:41372 ESTABLISHED
tcp6 0 0 :::22 :::* LISTEN
udp 0 0 127.0.0.53:53 0.0.0.0:*
```

### Command Breakdown

```bash
netstat -an | head
```

- **`netstat`** – Displays network connections.
- **`-a`** – Shows all sockets.
- **`-n`** – Displays numerical IP addresses and ports.
- **`|` (pipe)** – Passes output to another command.
- **`head`** – Displays only the first 10 lines.

---

# Command Summary

| Task | Command |
|------|---------|
| Show IP address | `hostname -I` |
| Display network interfaces | `ip addr show` |
| Test connectivity | `ping` |
| Trace packet route | `traceroute` |
| Trace packet route (non-root) | `tracepath` |
| Show listening ports | `ss -tunlp` |
| DNS lookup | `dig` |
| Quick DNS lookup | `nslookup` |
| Fetch webpage | `curl` |
| Fetch HTTP headers only | `curl -I` |
| View network connections | `netstat -an` |

---

# Networking Troubleshooting Workflow

```text
Check IP Address
        │
        ▼
hostname -I
        │
        ▼
ip addr show
        │
        ▼
Check Connectivity
        │
        ▼
ping
        │
        ▼
Trace Network Path
        │
        ├───────────────┐
        ▼               ▼
 traceroute        tracepath
        │
        ▼
Check Open Ports
        │
        ▼
ss -tunlp
        │
        ▼
Verify DNS
        │
        ├───────────┐
        ▼           ▼
      dig      nslookup
        │
        ▼
Test HTTP Response
        │
        ▼
curl / curl -I
        │
        ▼
Inspect Active Connections
        │
        ▼
netstat -an
```
````
