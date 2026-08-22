# 90 Days of DevOps — Day 29: Docker

## Task 1: What is Docker?

### 1. What is a Container and Why Do We Need Them?

A **container** is a lightweight, isolated environment that packages an application together with everything it needs to run, such as libraries, dependencies, configuration files, and runtime components.

Containers allow applications to run consistently across different environments.

### Why do we need containers?

Containers help solve problems such as:

* "It works on my machine" issues.
* Dependency conflicts between applications.
* Differences between development, testing, and production environments.
* Slow application deployment.
* Difficult application scaling.

For example, instead of installing Nginx, its dependencies, and configuration manually on every server, we can run an Nginx container using a Docker image.

---

### 2. Containers vs Virtual Machines

| Feature        | Containers               | Virtual Machines              |
| -------------- | ------------------------ | ----------------------------- |
| Virtualization | OS-level                 | Hardware-level                |
| OS             | Share the host kernel    | Each VM has its own OS/kernel |
| Size           | Usually MBs              | Usually GBs                   |
| Startup        | Seconds or less          | Usually minutes               |
| Resource usage | Low                      | Higher                        |
| Isolation      | Process-level isolation  | Stronger isolation            |
| Performance    | Near-native              | More overhead                 |
| Density        | Many containers per host | Fewer VMs per host            |

### Real Difference

A virtual machine virtualizes an entire computer, including its operating system.

A container virtualizes the **application environment**. Containers share the host operating system kernel while keeping applications isolated from each other.

```text
Virtual Machine
+----------------------+
| Application          |
| Libraries            |
| Guest OS             |
| Virtual Hardware     |
+----------------------+

Container
+----------------------+
| Application          |
| Libraries            |
+----------------------+
| Docker / Container   |
| Runtime              |
+----------------------+
| Host OS Kernel       |
+----------------------+
```

---

### 3. Docker Architecture

Docker uses a client-server architecture.

The major components are:

#### Docker Client

The Docker CLI is what we use to interact with Docker.

Example:

```bash
docker run nginx
```

The client sends the request to the Docker daemon.

#### Docker Daemon

The Docker daemon (`dockerd`) runs in the background.

It is responsible for:

* Building images.
* Downloading images.
* Creating containers.
* Starting and stopping containers.
* Managing networks and volumes.

#### Docker Image

An image is a read-only template used to create containers.

Examples:

```text
nginx
ubuntu
redis
mysql
```

An image contains the application and the dependencies required to run it.

#### Docker Container

A container is a running instance of an image.

```text
nginx image
     |
     +----> nginx container 1
     |
     +----> nginx container 2
```

One image can be used to create multiple containers.

#### Docker Registry

A registry stores Docker images.

The most common public registry is **Docker Hub**.

For example:

```bash
docker pull nginx
```

Docker downloads the Nginx image from a registry.

---

### Docker Architecture in My Own Words

```text
                    Docker Registry
                    (Docker Hub)
                         |
                         | pull / push
                         v
+-------------+    +-------------+
| Docker CLI  | -> | Docker      |
|   Client    |    | Daemon      |
+-------------+    +-------------+
                         |
              +----------+----------+
              |          |          |
              v          v          v
           Images    Containers   Networks
              |
              v
        Running Application
```

In simple terms:

**I use the Docker client to give commands. The Docker daemon performs the work. It uses images to create containers, while registries are used to store and download images.**

---

# Task 2: Install Docker

## 1. Install Docker

Docker can be installed on Linux, Windows, or macOS.

On Ubuntu, Docker Engine can be installed using Docker's official installation instructions.

After installation, verify Docker with:

```bash
docker --version
```

Example output:

```text
Docker version 28.x.x, build xxxxxxx
```

You can also run:

```bash
docker info
```

This displays information about the Docker installation and daemon.

---

## 2. Verify the Installation

Run:

```bash
docker run hello-world
```

If Docker is installed correctly, Docker downloads the `hello-world` image if it is not already available locally and then creates a container from it.

---

## 3. Run the `hello-world` Container

```bash
docker run hello-world
```

The container prints a message explaining that:

1. The Docker client contacted the Docker daemon.
2. The daemon downloaded the `hello-world` image.
3. The daemon created a container from that image.
4. The container executed the program inside the image.
5. The program produced output and the container stopped.

This is a simple demonstration of the Docker workflow.

```text
docker run
    |
    v
Docker Client
    |
    v
Docker Daemon
    |
    v
Pull Image if needed
    |
    v
Create Container
    |
    v
Run Application
    |
    v
Container exits
```

---

# Task 3: Run Real Containers

## 1. Run an Nginx Container

Download and run Nginx:

```bash
docker run -d -p 8080:80 nginx
```

Explanation:

```text
-d       = Run in detached/background mode
-p       = Map a host port to a container port
8080     = Host port
80       = Container port
nginx    = Docker image
```

Now open this in a browser:

```text
http://localhost:8080
```

You should see the Nginx welcome page.

The port mapping works like this:

```text
Browser
   |
   | localhost:8080
   v
Host Port 8080
   |
   | Docker port mapping
   v
Container Port 80
   |
   v
Nginx
```

---

## 2. Run an Ubuntu Container in Interactive Mode

Run:

```bash
docker run -it ubuntu bash
```

Explanation:

```text
-i = Interactive
-t = Allocate a terminal
ubuntu = Ubuntu image
bash = Start Bash shell
```

After running the command, you will get a shell inside the Ubuntu container.

Try:

```bash
ls
```

```bash
pwd
```

```bash
cat /etc/os-release
```

```bash
whoami
```

You can exit the container with:

```bash
exit
```

---

## 3. List All Running Containers

```bash
docker ps
```

This displays currently running containers.

Example:

```text
CONTAINER ID   IMAGE   COMMAND   STATUS   PORTS   NAMES
```

---

## 4. List All Containers

To show running and stopped containers:

```bash
docker ps -a
```

The `-a` option means **all containers**.

---

## 5. Stop and Remove a Container

First find the container:

```bash
docker ps
```

Stop it:

```bash
docker stop <container_id>
```

Remove it:

```bash
docker rm <container_id>
```

You can also use the container name:

```bash
docker stop my-nginx
docker rm my-nginx
```

---

# Task 4: Explore Docker

## 1. Run a Container in Detached Mode

Detached mode runs the container in the background.

Example:

```bash
docker run -d nginx
```

Without `-d`, the terminal is attached to the container's process.

With `-d`, Docker returns the container ID and gives control back to the terminal.

```bash
docker run -d nginx
```

Check that it is running:

```bash
docker ps
```

### What is different?

* The container runs in the background.
* The terminal remains available for other commands.
* We can use commands such as `docker logs` to view its output.

---

## 2. Give a Container a Custom Name

Use the `--name` option:

```bash
docker run -d --name my-nginx nginx
```

Now the container can be referenced using its name instead of its ID:

```bash
docker stop my-nginx
```

```bash
docker start my-nginx
```

```bash
docker logs my-nginx
```

This is easier than remembering a long container ID.

---

## 3. Map a Port from the Container to the Host

Run:

```bash
docker run -d --name web-server -p 8080:80 nginx
```

The syntax is:

```text
-p HOST_PORT:CONTAINER_PORT
```

Therefore:

```text
-p 8080:80
```

means:

```text
Host port 8080
       |
       v
Container port 80
       |
       v
Nginx
```

Access Nginx at:

```text
http://localhost:8080
```

---

## 4. Check Logs of a Running Container

Use:

```bash
docker logs web-server
```

To continuously follow the logs:

```bash
docker logs -f web-server
```

Press `Ctrl+C` to stop following the logs.

Logs are useful for troubleshooting applications running inside containers.

---

## 5. Run a Command Inside a Running Container

First start a container:

```bash
docker run -d --name my-nginx nginx
```

Then execute a command inside it:

```bash
docker exec my-nginx ls
```

Open an interactive shell:

```bash
docker exec -it my-nginx bash
```

If Bash is not available in an image, try:

```bash
docker exec -it my-nginx sh
```

Once inside the container, commands such as these can be used:

```bash
ls
```

```bash
pwd
```

```bash
cat /etc/os-release
```

Exit with:

```bash
exit
```

---

# Useful Docker Commands Learned

| Command                             | Purpose                               |
| ----------------------------------- | ------------------------------------- |
| `docker --version`                  | Check Docker version                  |
| `docker info`                       | Display Docker information            |
| `docker run hello-world`            | Test Docker installation              |
| `docker run nginx`                  | Run an Nginx container                |
| `docker run -d nginx`               | Run in detached mode                  |
| `docker run -it ubuntu bash`        | Start an interactive Ubuntu container |
| `docker ps`                         | List running containers               |
| `docker ps -a`                      | List all containers                   |
| `docker stop <container>`           | Stop a container                      |
| `docker rm <container>`             | Remove a container                    |
| `docker start <container>`          | Start a stopped container             |
| `docker logs <container>`           | View container logs                   |
| `docker exec <container> <command>` | Execute a command inside a container  |
| `docker exec -it <container> bash`  | Open a shell inside a container       |
| `docker pull <image>`               | Download an image                     |
| `docker images`                     | List local images                     |

---

# Conclusion

Docker provides a lightweight way to package and run applications in isolated environments called **containers**.

The basic Docker workflow is:

```text
Docker Image
     |
     v
Docker Container
     |
     v
Running Application
```

Docker makes application deployment more consistent, portable, scalable, and easier to manage.

The key concepts learned in this task are:

* Containers
* Docker images
* Docker containers
* Docker daemon
* Docker client
* Docker registries
* Port mapping
* Detached mode
* Container names
* Container logs
* Executing commands inside containers
