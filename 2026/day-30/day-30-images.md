# 90 Days of DevOps — Day 30: Docker Images, Layers & Container Lifecycle

## Task 1: Docker Images

### 1. Pull the `nginx`, `ubuntu`, and `alpine` Images

Docker images can be downloaded from Docker Hub using `docker pull`.

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
```

To verify that the images were downloaded:

```bash
docker images
```

Example output:

```text
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
nginx        latest    xxxxxxxx       ...           ...
ubuntu       latest    xxxxxxxx       ...           ...
alpine       latest    xxxxxxxx       ...           ...
```

---

### 2. List All Images on the Machine

Use:

```bash
docker images
```

Or:

```bash
docker image ls
```

This displays information such as:

* Repository name
* Image tag
* Image ID
* Creation date
* Image size

Example:

```text
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        latest    abc123         2 days ago     200MB
ubuntu       latest    def456         3 days ago     80MB
alpine       latest    ghi789         3 days ago     8MB
```

> **Note:** Image sizes can change between releases and platforms, so the exact sizes on your machine may be different.

---

### 3. Ubuntu vs Alpine — Why Is Alpine Much Smaller?

**Alpine Linux** is much smaller than Ubuntu because it is designed to be a minimal Linux distribution.

### Ubuntu

Ubuntu is a general-purpose Linux distribution that includes many common libraries, utilities, and packages.

It is designed to provide a convenient environment for many different workloads.

### Alpine

Alpine focuses on being:

* Minimal
* Lightweight
* Security-oriented
* Efficient
* Suitable for containers

Alpine uses **musl libc** and **BusyBox** instead of the larger collection of libraries and utilities normally found in Ubuntu.

Therefore, an Alpine image can be only a few megabytes, while Ubuntu is considerably larger.

### Simple comparison

```text
Ubuntu
+-----------------------------+
| Linux userspace             |
| Many utilities              |
| Libraries                   |
| Package management tools    |
| Other common components     |
+-----------------------------+
       Larger image

Alpine
+-----------------------------+
| Minimal userspace           |
| BusyBox                     |
| musl libc                   |
| Essential utilities         |
+-----------------------------+
       Much smaller image
```

The smaller size can mean faster image downloads and less storage usage.

---

### 4. Inspect an Image

Use:

```bash
docker image inspect nginx
```

Docker returns detailed JSON information about the image.

You can see information such as:

* Image ID
* Repository tags
* Architecture
* Operating system
* Creation time
* Image configuration
* Environment variables
* Entrypoint
* Default command
* Exposed ports
* Root filesystem information
* Image layers

For example:

```bash
docker image inspect alpine
```

To see only selected information, you can use Go templates.

Example:

```bash
docker image inspect nginx --format '{{.Os}}/{{.Architecture}}'
```

Example output:

```text
linux/amd64
```

---

### 5. Remove an Image

First list the images:

```bash
docker images
```

Remove an image using its name:

```bash
docker rmi alpine
```

Or using the image ID:

```bash
docker rmi <IMAGE_ID>
```

If a container is still using the image, Docker may prevent its removal.

You can first remove the container using:

```bash
docker rm <CONTAINER_ID>
```

Then remove the image.

---

# Task 2: Image Layers

## 1. Run `docker image history nginx`

Run:

```bash
docker image history nginx
```

Example output:

```text
IMAGE        CREATED       CREATED BY                          SIZE
xxxxxxxx     2 days ago    CMD ["nginx" "-g" "daemon off;"]   0B
xxxxxxxx     2 days ago    EXPOSE map[80/tcp:{}]              0B
xxxxxxxx     2 days ago    COPY ...                            50MB
xxxxxxxx     2 days ago    RUN ...                             20MB
xxxxxxxx     2 days ago    /bin/sh ...                         0B
```

The exact output depends on the current Nginx image version.

---

## 2. What Are the Layers?

A Docker image is made up of multiple **read-only layers**.

Each instruction in a Dockerfile can create a new filesystem layer.

For example:

```dockerfile
FROM ubuntu

RUN apt-get update

RUN apt-get install -y nginx

COPY index.html /var/www/html/
```

Conceptually:

```text
+-----------------------------+
| COPY index.html             |
+-----------------------------+
| Install nginx               |
+-----------------------------+
| apt-get update              |
+-----------------------------+
| Ubuntu base image           |
+-----------------------------+
```

Some entries in `docker image history` show a size, while others show `0B`.

A `0B` entry can represent metadata/configuration changes rather than a filesystem change that adds data to the image.

---

## 3. What Are Layers and Why Does Docker Use Them?

### What are layers?

Layers are individual filesystem changes that are combined to form a Docker image.

Each layer is generally immutable and can be reused by other images.

### Why does Docker use layers?

Docker uses layers mainly for **efficiency and reuse**.

For example:

```text
Image A
+----------------+
| Application A  |
+----------------+
| Ubuntu layer   |
+----------------+

Image B
+----------------+
| Application B  |
+----------------+
| Ubuntu layer   |
+----------------+
```

Both images can reuse the same Ubuntu layer.

This provides several benefits:

* Saves disk space.
* Makes image downloads more efficient.
* Speeds up image builds.
* Allows Docker to cache unchanged layers.
* Makes it easier to distribute images.

### Docker Layer Concept

```text
Docker Image
     |
     +--- Layer 4: Application
     |
     +--- Layer 3: Configuration
     |
     +--- Layer 2: Packages
     |
     +--- Layer 1: Base OS
```

When an image is rebuilt and an earlier layer has not changed, Docker can reuse the cached layer instead of rebuilding it.

---

# Task 3: Container Lifecycle

For this exercise, create an Nginx container named `lifecycle-demo`.

## 1. Create a Container Without Starting It

Use `docker create`:

```bash
docker create --name lifecycle-demo nginx
```

The container is created but not started.

Check its status:

```bash
docker ps -a
```

You should see a status similar to:

```text
Created
```

---

## 2. Start the Container

```bash
docker start lifecycle-demo
```

Check:

```bash
docker ps -a
```

The status should now show:

```text
Up
```

---

## 3. Pause the Container

```bash
docker pause lifecycle-demo
```

Check:

```bash
docker ps -a
```

The status should show something similar to:

```text
Up ... (Paused)
```

You can also check with:

```bash
docker inspect lifecycle-demo --format '{{.State.Status}}'
```

---

## 4. Unpause the Container

Resume the container:

```bash
docker unpause lifecycle-demo
```

Check:

```bash
docker ps -a
```

The container should return to:

```text
Up
```

---

## 5. Stop the Container

```bash
docker stop lifecycle-demo
```

Check:

```bash
docker ps -a
```

The status should show:

```text
Exited
```

Stopping gives the application inside the container a chance to terminate gracefully.

---

## 6. Restart the Container

```bash
docker restart lifecycle-demo
```

Check:

```bash
docker ps -a
```

The container should be running again.

---

## 7. Kill the Container

First:

```bash
docker kill lifecycle-demo
```

Check:

```bash
docker ps -a
```

The container should show an exited state.

### Difference Between `stop` and `kill`

`docker stop` attempts a graceful shutdown.

```bash
docker stop lifecycle-demo
```

`docker kill` immediately sends a kill signal to the container's main process.

```bash
docker kill lifecycle-demo
```

---

## 8. Remove the Container

Remove the stopped container:

```bash
docker rm lifecycle-demo
```

Verify:

```bash
docker ps -a
```

The `lifecycle-demo` container should no longer appear.

---

## Container Lifecycle Summary

```text
             docker create
                  |
                  v
              Created
                  |
             docker start
                  |
                  v
               Running
               /     \
              /       \
     docker pause    docker stop
           |             |
           v             v
        Paused         Exited
           |             |
     docker unpause   docker start
           |             |
           +-----> Running
                         |
                    docker kill
                         |
                         v
                       Exited
                         |
                     docker rm
                         |
                         v
                      Removed
```

---

# Task 4: Working with Running Containers

## 1. Run an Nginx Container in Detached Mode

Run:

```bash
docker run -d --name nginx-demo -p 8080:80 nginx
```

Check that it is running:

```bash
docker ps
```

Open the following address in your browser:

```text
http://localhost:8080
```

You should see the Nginx welcome page.

---

## 2. View Its Logs

Use:

```bash
docker logs nginx-demo
```

This displays the container's standard output and error output.

For Nginx, you may see access-related output after making requests to the server.

---

## 3. View Real-Time Logs

Use the `-f` option:

```bash
docker logs -f nginx-demo
```

The `-f` option means **follow**.

Docker keeps displaying new log entries as they are generated.

While the logs are being followed, open:

```text
http://localhost:8080
```

or refresh the page.

You may see a new request appear in the logs.

Press:

```text
Ctrl+C
```

to stop following the logs.

---

## 4. Exec into the Container and Explore the Filesystem

Open a shell inside the Nginx container:

```bash
docker exec -it nginx-demo bash
```

If Bash is not available:

```bash
docker exec -it nginx-demo sh
```

Once inside, try:

```bash
pwd
```

```bash
ls
```

```bash
ls -la
```

Check the Nginx configuration:

```bash
ls /etc/nginx
```

Look at the default web files:

```bash
ls /usr/share/nginx/html
```

Check the operating system information:

```bash
cat /etc/os-release
```

Exit the container:

```bash
exit
```

---

## 5. Run a Single Command Inside the Container

You do not need to open an interactive shell to execute a command.

For example:

```bash
docker exec nginx-demo ls /usr/share/nginx/html
```

Another example:

```bash
docker exec nginx-demo nginx -v
```

You can also check the hostname:

```bash
docker exec nginx-demo hostname
```

This is useful for automation and troubleshooting.

---

## 6. Inspect the Container

Use:

```bash
docker inspect nginx-demo
```

This returns detailed JSON information about the container.

It includes:

* Container ID
* Container name
* Image
* Creation time
* Current state
* Network information
* IP address
* Port mappings
* Mounts
* Environment variables
* Command
* Entrypoint
* Restart policy

### Find the Container IP Address

Use:

```bash
docker inspect nginx-demo --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Example:

```text
172.17.0.2
```

The actual IP address can be different on your machine.

### Find Port Mappings

Use:

```bash
docker port nginx-demo
```

Example:

```text
80/tcp -> 0.0.0.0:8080
```

This means:

```text
Host port 8080
       |
       v
Container port 80
```

### Find Mounts

Use:

```bash
docker inspect nginx-demo --format '{{json .Mounts}}'
```

If no volumes or bind mounts were configured, the result may be:

```text
[]
```

You can also view the complete information:

```bash
docker inspect nginx-demo
```

and find the `"Mounts"` section.

---

# Task 5: Cleanup

## 1. Stop All Running Containers in One Command

First, list the running containers:

```bash
docker ps
```

To stop all running containers:

```bash
docker stop $(docker ps -q)
```

### Explanation

```text
docker ps -q
```

returns only the IDs of running containers.

Those IDs are passed to:

```text
docker stop
```

So the complete command stops every currently running container.

---

## 2. Remove All Stopped Containers in One Command

Use:

```bash
docker container prune
```

Docker asks for confirmation:

```text
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N]
```

Enter:

```text
y
```

This removes containers that are no longer running.

### Alternative

You can use:

```bash
docker rm $(docker ps -aq)
```

However, `docker container prune` is safer and more straightforward when the goal is specifically to remove stopped containers.

---

## 3. Remove Unused Images

To remove unused images:

```bash
docker image prune
```

Docker asks for confirmation before removing dangling images.

To remove all images that are not associated with any container:

```bash
docker image prune -a
```

Be careful with `-a` because it can remove images that you may want to keep locally.

---

## 4. Check How Much Disk Space Docker Is Using

Use:

```bash
docker system df
```

Example output:

```text
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          5         2         1.2GB     800MB
Containers      4         1         100MB     80MB
Local Volumes   2         1         500MB     200MB
Build Cache     ...       ...       ...       ...
```

This command shows how much disk space is being used by:

* Images
* Containers
* Local volumes
* Build cache

For more detailed information:

```bash
docker system df -v
```

---

# Important Docker Cleanup Commands

| Command                  | Purpose                        |
| ------------------------ | ------------------------------ |
| `docker container prune` | Remove stopped containers      |
| `docker image prune`     | Remove dangling images         |
| `docker image prune -a`  | Remove unused images           |
| `docker volume prune`    | Remove unused volumes          |
| `docker network prune`   | Remove unused networks         |
| `docker system df`       | Show Docker disk usage         |
| `docker system prune`    | Remove unused Docker resources |

A more aggressive cleanup command is:

```bash
docker system prune
```

To also remove unused images:

```bash
docker system prune -a
```

Use aggressive cleanup commands carefully because they can delete resources you may still need.

---

# Complete Command Summary

## Images

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine

docker images
docker image ls

docker image inspect nginx

docker image history nginx

docker rmi alpine
```

## Container Lifecycle

```bash
docker create --name lifecycle-demo nginx
docker start lifecycle-demo
docker pause lifecycle-demo
docker unpause lifecycle-demo
docker stop lifecycle-demo
docker restart lifecycle-demo
docker kill lifecycle-demo
docker rm lifecycle-demo
```

Check the state after each operation:

```bash
docker ps -a
```

## Running Containers

```bash
docker run -d --name nginx-demo -p 8080:80 nginx

docker logs nginx-demo
docker logs -f nginx-demo

docker exec -it nginx-demo bash
docker exec nginx-demo ls /usr/share/nginx/html

docker inspect nginx-demo
docker port nginx-demo
```

## Cleanup

```bash
docker stop $(docker ps -q)

docker container prune

docker image prune
docker image prune -a

docker system df
```

---


