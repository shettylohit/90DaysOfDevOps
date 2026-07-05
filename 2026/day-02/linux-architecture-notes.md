1. Core Components of Linux

Linux is made up of three main components:

a) Kernel

The kernel is the core of the Linux operating system. It acts as a bridge between hardware and software.

Functions of the kernel:

Manages CPU, memory, and storage
Controls hardware devices through device drivers
Handles process scheduling
Manages file systems
Provides security and system calls for applications

Example: When you open a program like Firefox, the kernel allocates memory and CPU time for it.

b) User Space

User space is where applications and user programs run.

It includes:

Command-line shell (Bash)
GUI applications
Utilities (ls, cp, grep)
Libraries (glibc)

Programs in user space cannot directly access hardware. They request services from the kernel using system calls.

Example:
When you type:

ls

The ls program runs in user space and asks the kernel to read directory information.

c) Init/Systemd

The init system is the first process started by the kernel after booting.

Traditionally Linux used init, but most modern Linux distributions use systemd.

Responsibilities:

Starts system services
Initializes the operating system
Manages background processes (daemons)
Shuts down or reboots the system properly

systemd runs as PID 1, meaning it is the first userspace process started during boot.

2. How Processes Are Created and Managed

A process is a running instance of a program.

Process Creation

Linux creates processes using the following system calls:

Step 1: fork()
Creates a new child process.
The child is almost identical to the parent.
Step 2: exec()
Replaces the child process with a new program.

Example:

bash
   |
   |-- fork()
   |
child process
   |
   |-- exec(ls)
Step 3: wait()

The parent process waits until the child finishes execution.

Process States

A process can be in several states:

Running – Currently executing.
Ready – Waiting for CPU time.
Sleeping/Waiting – Waiting for an event or input.
Stopped – Suspended.
Zombie – Finished execution but waiting for the parent to collect its exit status.
Process Management

The Linux kernel manages processes by:

Scheduling CPU time
Allocating memory
Assigning process IDs (PIDs)
Managing priorities
Handling inter-process communication (IPC)

Useful commands:

ps
top
htop
kill
nice
3. What systemd Does and Why It Matters

systemd is the default initialization and service manager used by most modern Linux distributions.

It starts immediately after the kernel finishes booting.

It is always Process ID (PID) 1.

Functions of systemd
1. Boots the System

Starts the operating system and initializes services.

Example:

Networking
Logging
SSH server
2. Manages Services

Starts, stops, restarts, and monitors services.

Example:

systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl status nginx
3. Dependency Management

Starts services in the correct order.

Example:

Network starts before the web server.
Database starts before applications that depend on it.
4. Parallel Startup

Unlike older init systems, systemd starts multiple independent services simultaneously, reducing boot time.

5. Logging

Works with the system journal to collect logs.

Example:

journalctl
journalctl -u nginx
6. Resource Management

Controls CPU, memory, and other resources for processes using Linux control groups (cgroups).
