# Docker Cheat Sheet
 
A quick reference guide for Docker commands, Docker Compose, and Dockerfile instructions.

## 1\. Container Commands
 
Commands for creating, managing, and interacting with containers.
 

| Command | Description | Example |
| ------- | ----------- | ------- |
| `docker run` | Create and start a container | `docker run -d --name web nginx` |
| `docker ps` | List running containers | `docker ps` |
| `docker ps -a` | List all containers | `docker ps -a` |
| `docker stop` | Stop a running container | `docker stop web` |
| `docker rm` | Remove a stopped container | `docker rm web` |
| `docker exec` | Execute a command inside a running container | `docker exec -it web sh` |
| `docker logs` | View container logs | `docker logs web` |
| `docker logs -f` | Follow live container logs | `docker logs -f web` |

### Useful Examples
 

    # Run Nginx in the background
    docker run -d --name web -p 8080:80 nginx
    
    # Run an interactive Ubuntu container
    docker run -it --name ubuntu ubuntu bash
    
    # List running containers
    docker ps
    
    # Stop and remove a container
    docker stop web
    docker rm web
    
    # Open a shell inside a running container
    docker exec -it web sh
    
    # View the last 100 log lines
    docker logs --tail 100 web
    

---
 

## 2\. Image Commands
 
Commands for building, downloading, uploading, tagging, and managing images.
 <table><tbody><tr><th >Command</th><th >Description</th><th >Example</th></tr><tr><td >`docker build`</td><td >Build an image from a Dockerfile</td><td >`docker build -t myapp:1.0 .`</td></tr><tr><td >`docker pull`</td><td >Download an image</td><td >`docker pull nginx:latest`</td></tr><tr><td >`docker push`</td><td >Upload an image to a registry</td><td >`docker push username/myapp:1.0`</td></tr><tr><td >`docker tag`</td><td >Add another tag to an image</td><td >`docker tag myapp:1.0 username/myapp:1.0`</td></tr><tr><td >`docker images`</td><td >List local images</td><td >`docker images`</td></tr><tr><td >`docker image ls`</td><td >List local images</td><td >`docker image ls`</td></tr><tr><td >`docker image rm`</td><td >Remove an image</td><td >`docker image rm myapp:1.0`</td></tr></tbody></table>

### Useful Examples
 

    # Build an image from the current directory
    docker build -t myapp:1.0 .
    
    # Build without using the build cache
    docker build --no-cache -t myapp:1.0 .
    
    # Download an image
    docker pull nginx:latest
    
    # Tag an image for Docker Hub
    docker tag myapp:1.0 username/myapp:1.0
    
    # Log in to a registry
    docker login
    
    # Push an image to Docker Hub
    docker push username/myapp:1.0
    
    # List images
    docker images
    
    # Remove an image
    docker image rm myapp:1.0
    

**Note:** Replace `username` with your Docker Hub username. You must have permission to push to the target repository.
 
---
 

## 3\. Volume Commands
 
Volumes provide persistent storage for containers.
 <table><tbody><tr><th >Command</th><th >Description</th><th >Example</th></tr><tr><td >`docker volume create`</td><td >Create a volume</td><td >`docker volume create app-data`</td></tr><tr><td >`docker volume ls`</td><td >List volumes</td><td >`docker volume ls`</td></tr><tr><td >`docker volume inspect`</td><td >View volume details</td><td >`docker volume inspect app-data`</td></tr><tr><td >`docker volume rm`</td><td >Remove a volume</td><td >`docker volume rm app-data`</td></tr></tbody></table>

### Useful Examples
 

    # Create a volume
    docker volume create app-data
    
    # List volumes
    docker volume ls
    
    # Inspect a volume
    docker volume inspect app-data
    
    # Use a volume with a container
    docker run -d \
      --name db \
      -v app-data:/var/lib/postgresql/data \
      postgres
    
    # Remove a volume (only when no container uses it)
    docker volume rm app-data
    

**Important:**
 

*   Removing a container does not normally remove its named volumes.
     
*   Removing a volume deletes its stored data.
     
*   Verify that the data is no longer needed before deleting a volume.
     

---
 

## 4\. Network Commands
 
Docker networks allow containers to communicate with each other.
 <table><tbody><tr><th >Command</th><th >Description</th><th >Example</th></tr><tr><td >`docker network create`</td><td >Create a network</td><td >`docker network create app-network`</td></tr><tr><td >`docker network ls`</td><td >List networks</td><td >`docker network ls`</td></tr><tr><td >`docker network inspect`</td><td >Inspect a network</td><td >`docker network inspect app-network`</td></tr><tr><td >`docker network connect`</td><td >Connect a container to a network</td><td >`docker network connect app-network web`</td></tr><tr><td >`docker network disconnect`</td><td >Disconnect a container from a network</td><td >`docker network disconnect app-network web`</td></tr></tbody></table>

### Useful Examples
 

    # Create a custom bridge network
    docker network create app-network
    
    # List networks
    docker network ls
    
    # Inspect a network
    docker network inspect app-network
    
    # Start a container on the network
    docker run -d \
      --name web \
      --network app-network \
      nginx
    
    # Connect an existing container to a network
    docker network connect app-network web
    
    # Disconnect a container from a network
    docker network disconnect app-network web
    

**Tip:** Containers on the same user-defined bridge network can generally communicate using container names or network aliases as hostnames, provided the destination service is listening and network access is allowed.
 
---
 

## 5\. Docker Compose Commands
 
Docker Compose manages multi-container applications using a `compose.yaml` or `docker-compose.yml` file.
 <table><tbody><tr><th >Command</th><th >Description</th><th >Example</th></tr><tr><td >`docker compose up`</td><td >Create and start services</td><td >`docker compose up -d`</td></tr><tr><td >`docker compose down`</td><td >Stop and remove services and networks</td><td >`docker compose down`</td></tr><tr><td >`docker compose ps`</td><td >List Compose containers</td><td >`docker compose ps`</td></tr><tr><td >`docker compose logs`</td><td >View service logs</td><td >`docker compose logs`</td></tr><tr><td >`docker compose build`</td><td >Build or rebuild service images</td><td >`docker compose build`</td></tr></tbody></table>

### Useful Examples
 

    # Start services in the foreground
    docker compose up
    
    # Start services in the background
    docker compose up -d
    
    # Build images and start services
    docker compose up -d --build
    
    # List services and their container status
    docker compose ps
    
    # View logs from all services
    docker compose logs
    
    # Follow live logs
    docker compose logs -f
    
    # View logs for a specific service
    docker compose logs -f web
    
    # Build or rebuild images
    docker compose build
    
    # Stop and remove containers and networks
    docker compose down
    
    # Also remove Compose-managed named and anonymous volumes
    docker compose down -v
    

**Important:** `docker compose down -v` can delete persistent data stored in the volumes it removes. Use it carefully with databases.
 
---
 

## 6\. Cleanup Commands
 
Commands for checking disk usage and removing unused Docker resources.
 <table><tbody><tr><th >Command</th><th >Description</th><th >Example</th></tr><tr><td >`docker system df`</td><td >Show Docker disk usage</td><td >`docker system df`</td></tr><tr><td >`docker system df -v`</td><td >Show detailed disk usage</td><td >`docker system df -v`</td></tr><tr><td >`docker container prune`</td><td >Remove stopped containers</td><td >`docker container prune`</td></tr><tr><td >`docker image prune`</td><td >Remove dangling images by default</td><td >`docker image prune`</td></tr><tr><td >`docker image prune -a`</td><td >Remove unused images not referenced by containers</td><td >`docker image prune -a`</td></tr><tr><td >`docker volume prune`</td><td >Remove unused local volumes</td><td >`docker volume prune`</td></tr><tr><td >`docker network prune`</td><td >Remove unused networks</td><td >`docker network prune`</td></tr><tr><td >`docker system prune`</td><td >Remove several categories of unused resources</td><td >`docker system prune`</td></tr></tbody></table>

### Useful Examples
 

    # Check Docker disk usage
    docker system df
    
    # Show detailed disk usage
    docker system df -v
    
    # Remove stopped containers
    docker container prune
    
    # Remove dangling images
    docker image prune
    
    # Remove all images not used by existing containers
    docker image prune -a
    
    # Remove unused networks
    docker network prune
    
    # Remove unused local volumes
    docker volume prune
    
    # General cleanup of unused containers, networks,
    # dangling images, and build cache
    docker system prune
    

### Cleanup Warnings
 

*   Most prune commands prompt for confirmation. Add `-f` to skip the prompt.
     
*   `docker system prune -a` also removes unused images beyond dangling images.
     
*   `docker system prune --volumes` additionally prunes eligible unused anonymous volumes.
     
*   `docker volume prune` can delete data you may want to keep.
     
*   Prune commands do not remove resources that Docker considers in use.
     

**Best practice:** Always inspect what is safe to remove before performing cleanup on a production machine.
 
---
 

## 7\. Dockerfile Instructions
 
A Dockerfile defines how Docker builds an image.
 <table><tbody><tr><th >Instruction</th><th >Description</th><th >Example</th></tr><tr><td >`FROM`</td><td >Select the base image</td><td >`FROM node:22-alpine`</td></tr><tr><td >`RUN`</td><td >Execute commands during the build</td><td >`RUN npm install`</td></tr><tr><td >`COPY`</td><td >Copy files from the build context into the image</td><td >`COPY . .`</td></tr><tr><td >`WORKDIR`</td><td >Set the working directory for subsequent instructions</td><td >`WORKDIR /app`</td></tr><tr><td >`EXPOSE`</td><td >Document the port the application listens on</td><td >`EXPOSE 3000`</td></tr><tr><td >`CMD`</td><td >Provide the default command or arguments when a container starts</td><td >`CMD ["npm", "start"]`</td></tr><tr><td >`ENTRYPOINT`</td><td >Define the executable that runs when a container starts</td><td >`ENTRYPOINT ["node"]`</td></tr></tbody></table>

### Example Dockerfile
 

    # Select the base image
    FROM node:22-alpine
    
    # Set the working directory
    WORKDIR /app
    
    # Copy dependency manifests first
    COPY package*.json ./
    
    # Install dependencies during the build
    RUN npm install
    
    # Copy application files
    COPY . .
    
    # Document the application port
    EXPOSE 3000
    
    # Set the default startup command
    CMD ["npm", "start"]
    

### Instruction Explanations
 
`FROM`
 
Specifies the base image used to build the application image.
 

    FROM python:3.12-slim
    

`RUN`
 
Executes commands during the image build process. The resulting changes are included in the image.
 

    RUN apt-get update && apt-get install -y curl
    

`COPY`
 
Copies files or directories from the build context into the image.
 

    COPY app.py /app/app.py
    

`WORKDIR`
 
Sets the working directory for subsequent instructions such as `RUN`, `COPY`, and `CMD`.
 

    WORKDIR /app
    

`EXPOSE`
 
Documents the port on which the application is expected to listen. It does not publish the port to the host.
 

    EXPOSE 8080
    

To publish the port when running the container:
 

    docker run -p 8080:8080 myapp
    

`CMD`
 
Specifies the default command or arguments used when the container starts. Runtime arguments can override a command-form `CMD`.
 

    CMD ["python", "app.py"]
    

`ENTRYPOINT`
 
Specifies the main executable for the container. With the exec form, arguments supplied to `docker run` are appended to the entrypoint.
 

    ENTRYPOINT ["python"]
    CMD ["app.py"]
    

With this combination, the container runs `python app.py` by default. Supplying another argument to `docker run` replaces the default `CMD` arguments.
 
---
 

