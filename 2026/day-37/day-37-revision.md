# 1. What is the difference between an image and a container?
Image: A read-only template that contains the application code, dependencies, and configuration needed to run an application.
Container: A running or stopped instance of an image with its own writable layer.

Example: A Docker image is like a class, and a container is like an object created from that class.


# 2. What happens to data inside a container when you remove it?

When you remove a container, the data stored in its writable layer is deleted permanently.

Docker volume: Data remains safe even if the container is removed.
Bind mount: Data remains on the host machine.
Container writable layer: Data stored only inside the container is lost when the container is removed.

# 3. How do two containers on the same custom network communicate?

Two containers connected to the same custom Docker network can communicate using each other's container names or network aliases.

For example, if a container named backend needs to communicate with a container named database, it can connect using the hostname database and the database's listening port.

Step 1: Create a custom network
docker network create my-network

Step 2: Start the database container
```
docker run -d \
  --name database \
  --network my-network \
  postgres

Step 3: Start the backend container
docker run -it \
  --name backend \
  --network my-network \
  alpine sh
```

From the backend container, the database can be accessed using the hostname database, provided the required client tools, credentials, and database configuration are available.

Key takeaway: Custom Docker networks provide automatic DNS resolution for container names, allowing containers to communicate without hardcoding IP addresses.

# 4. What does docker compose down -v do differently from docker compose down?
```
docker compose down
```
Stops and removes containers.
Removes Compose-managed networks.
Preserves named volumes.
```
docker compose down -v
```
Does everything that docker compose down does, but also removes:

Named volumes declared in the Compose file.
Anonymous volumes attached to the containers.

Important: Removing volumes can permanently delete database data stored in those volumes. Use this command carefully when working with persistent data.

# 5. Why are multi-stage builds useful?

Multi-stage builds allow you to use multiple FROM instructions in a Dockerfile to separate building an application from running it.

Benefits
Smaller final image size.
No need to include build tools in the final image.
Improved security by reducing unnecessary packages.
Cleaner and more efficient deployments.
Example: Multi-stage Go Dockerfile
```
FROM golang:alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o app .

FROM alpine:latest

COPY --from=builder /app/app /app
CMD ["/app"]

```
The final image contains the compiled application rather than the entire Go build environment.

Key takeaway: Multi-stage builds reduce image size and help keep production images lean.

# 6. What is the difference between COPY and ADD?
COPY: Copies files and directories from the build context into the image.
ADD: Can do everything COPY does, plus automatically extract supported local tar archives and fetch remote URLs.
Best practice

Use COPY by default because its behavior is simpler and more predictable. Use ADD when you specifically need its additional functionality.

# 7. What does -p 8080:80 mean?

In a Docker command, -p 8080:80 publishes a container port on a host port.

Example
```
docker run -p 8080:80 nginx
```

Here:

8080: Port on the host machine.
80: Port inside the container.

You can access the Nginx server through http://localhost:8080, assuming the container is running and the service is accessible on that port.

Key takeaway: The syntax is -p HOST_PORT:CONTAINER_PORT.

# 8. How do you check how much disk space Docker is using?
Check overall Docker disk usage
```
docker system df
```
This displays disk usage by Docker images, containers, local volumes, and the build cache.

Get detailed disk usage information

```
docker system df -v
```

This provides more detailed information about Docker disk usage.

Check individual container sizes
```
docker ps -as
```

This displays container sizes, including information about their writable layers.
```
docker ps -as	Shows container sizes
```
