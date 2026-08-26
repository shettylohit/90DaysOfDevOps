# Docker Challenge Tasks — Day 31

## Task 1: Your First Dockerfile

### 1. Create the project folder

```bash
mkdir my-first-image
cd my-first-image
```

### 2. Create the Dockerfile

Create a file named `Dockerfile`:

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

CMD ["echo", "Hello from my custom image!"]
```

### 3. Build the image

```bash
docker build -t my-ubuntu:v1 .
```

Check the image:

```bash
docker images
```

### 4. Run the container

```bash
docker run my-ubuntu:v1
```

### Expected output

```text
Hello from my custom image!
```

### Explanation

* `FROM ubuntu:latest` — Uses Ubuntu as the base image.
* `RUN` — Installs `curl` while building the image.
* `CMD` — Defines the default command that runs when the container starts.

---

# Task 2: Dockerfile Instructions

Create a new directory:

```bash
mkdir docker-instructions
cd docker-instructions
```

Create a file named `hello.txt`:

```text
Hello from Docker!
```

Create a `Dockerfile`:

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY hello.txt /app/hello.txt

EXPOSE 8080

CMD ["cat", "/app/hello.txt"]
```

### Build the image

```bash
docker build -t docker-instructions:v1 .
```

### Run the container

```bash
docker run docker-instructions:v1
```

### Expected output

```text
Hello from Docker!
```

### Understanding each instruction

| Instruction | Purpose                                                 |
| ----------- | ------------------------------------------------------- |
| `FROM`      | Specifies the base image                                |
| `RUN`       | Executes commands while building the image              |
| `COPY`      | Copies files from the host into the image               |
| `WORKDIR`   | Sets the working directory inside the container         |
| `EXPOSE`    | Documents the port the application is expected to use   |
| `CMD`       | Specifies the default command when the container starts |

> **Note:** `EXPOSE 8080` does not actually publish the port to the host. Port publishing is done with `docker run -p`.

---

# Task 3: CMD vs ENTRYPOINT

## Part 1: Using CMD

Create a directory:

```bash
mkdir cmd-example
cd cmd-example
```

Create a `Dockerfile`:

```dockerfile
FROM ubuntu:latest

CMD ["echo", "hello"]
```

Build the image:

```bash
docker build -t cmd-example:v1 .
```

Run normally:

```bash
docker run cmd-example:v1
```

Output:

```text
hello
```

Now run it with a custom command:

```bash
docker run cmd-example:v1 echo "custom command"
```

Output:

```text
custom command
```

### What happened?

`CMD` provides a **default command**, but the command can be completely replaced when using `docker run`.

---

## Part 2: Using ENTRYPOINT

Create another directory:

```bash
mkdir ../entrypoint-example
cd ../entrypoint-example
```

Create a `Dockerfile`:

```dockerfile
FROM ubuntu:latest

ENTRYPOINT ["echo"]
```

Build it:

```bash
docker build -t entrypoint-example:v1 .
```

Run it:

```bash
docker run entrypoint-example:v1
```

Output:

```text
```

Run it with additional arguments:

```bash
docker run entrypoint-example:v1 hello
```

Output:

```text
hello
```

Another example:

```bash
docker run entrypoint-example:v1 "Hello from Docker"
```

Output:

```text
Hello from Docker
```

### What happened?

With:

```dockerfile
ENTRYPOINT ["echo"]
```

Docker always starts with `echo`. Arguments supplied to `docker run` are appended to the entrypoint.

For example:

```bash
docker run entrypoint-example:v1 hello
```

effectively runs:

```bash
echo hello
```

## CMD vs ENTRYPOINT

| CMD                                               | ENTRYPOINT                                        |
| ------------------------------------------------- | ------------------------------------------------- |
| Provides a default command                        | Defines the main executable                       |
| Can easily be completely overridden               | Usually remains fixed                             |
| Useful when users may want to replace the command | Useful when the container has one primary purpose |
| Example: `CMD ["echo", "hello"]`                  | Example: `ENTRYPOINT ["echo"]`                    |

### When should you use them?

Use **CMD** when you want to provide a sensible default that users can easily replace.

Use **ENTRYPOINT** when your container should behave like a specific executable and command-line arguments should normally be passed to it.

You can also combine them:

```dockerfile
ENTRYPOINT ["echo"]
CMD ["hello"]
```

Running:

```bash
docker run my-image
```

runs approximately:

```bash
echo hello
```

while:

```bash
docker run my-image "Docker is awesome"
```

runs:

```bash
echo "Docker is awesome"
```

---

# Task 4: Build a Simple Web App Image

Create a project directory:

```bash
mkdir my-website
cd my-website
```

## 1. Create `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Docker Website</title>
</head>
<body>
    <h1>Hello from my Docker website!</h1>
    <p>This website is running inside an Nginx container.</p>
</body>
</html>
```

## 2. Create the Dockerfile

```dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html
```

The default Nginx web directory is:

```text
/usr/share/nginx/html
```

## 3. Build the image

```bash
docker build -t my-website:v1 .
```

Check the image:

```bash
docker images
```

## 4. Run the container

```bash
docker run -d -p 8080:80 --name my-website my-website:v1
```

### Understand the port mapping

```text
8080:80
  │   │
  │   └── Container port
  └────── Host port
```

Nginx listens on port `80` inside the container, while we access it through port `8080` on our machine.

Open your browser and visit:

```text
http://localhost:8080
```

You should see:

```text
Hello from my Docker website!

This website is running inside an Nginx container.
```

Stop the container when finished:

```bash
docker stop my-website
```

Remove it:

```bash
docker rm my-website
```

---

# Task 5: .dockerignore

The `.dockerignore` file tells Docker which files should not be included in the build context.

Inside your project directory, create:

```text
.dockerignore
```

Add:

```text
node_modules
.git
*.md
.env
```

For example, your project can look like this:

```text
my-project/
├── Dockerfile
├── .dockerignore
├── index.html
├── README.md
├── .env
├── .git/
└── node_modules/
```

Docker will ignore:

```text
node_modules
.git
*.md
.env
```

when sending the build context to the Docker daemon.

## Example Dockerfile

```dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html
```

Build it:

```bash
docker build -t my-project:v1 .
```

### Verify

You can inspect the resulting image:

```bash
docker run --rm my-project:v1 ls -la /usr/share/nginx/html
```

Files such as `README.md` and `.env` should not have been copied into the image.

> **Important:** `.dockerignore` prevents files from being sent as part of the build context. It is not a security mechanism for protecting secrets that were already copied into an image in a previous layer. Avoid putting secrets into Docker images in the first place.

---

# Task 6: Build Optimization

Docker builds images in layers. Docker can reuse previously built layers when the relevant Dockerfile instruction and its inputs have not changed.

## Example 1: Poor layer ordering

Consider:

```dockerfile
FROM ubuntu:latest

COPY . /app

RUN apt-get update && apt-get install -y curl

CMD ["echo", "Hello"]
```

If files copied by:

```dockerfile
COPY . /app
```

change frequently, Docker may need to rebuild the following layers as well.

---

## Example 2: Better layer ordering

A better Dockerfile might be:

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

CMD ["echo", "Hello"]
```

Here, the relatively stable dependency-installation step happens before the frequently changing application files are copied.

### Build the image

```bash
docker build -t optimized-image:v1 .
```

Change something in your application and build again:

```bash
docker build -t optimized-image:v2 .
```

During the second build, Docker may display output similar to:

```text
CACHED
```

for layers that haven't changed.

## Why does layer order matter?

Dockerfile instructions generally create image layers. Docker can reuse cached layers when their inputs haven't changed.

Therefore:

```text
Stable instructions
        ↓
Dependency installation
        ↓
Application source code
        ↓
Frequently changing files
```

is usually a better order than putting frequently changing files near the top.

### Key principle

> **Put expensive and rarely changing operations earlier, and frequently changing operations later.**

This reduces the amount of work Docker has to repeat during subsequent builds and can significantly improve build times.

---

# Final Challenge Summary

| Task   | Main Concept                                         |
| ------ | ---------------------------------------------------- |
| Task 1 | Create your first Dockerfile                         |
| Task 2 | Learn common Dockerfile instructions                 |
| Task 3 | Understand `CMD` vs `ENTRYPOINT`                     |
| Task 4 | Build and serve a website with Nginx                 |
| Task 5 | Use `.dockerignore`                                  |
| Task 6 | Understand Docker build cache and layer optimization |

## Useful Commands

```bash
# Build an image
docker build -t image-name:tag .

# List images
docker images

# Run a container
docker run image-name:tag

# Run in detached mode
docker run -d image-name:tag

# Map a port
docker run -d -p 8080:80 image-name:tag

# List running containers
docker ps

# List all containers
docker ps -a

# Stop a container
docker stop <container>

# Remove a container
docker rm <container>

# Remove an image
docker rmi <image>

# View container logs
docker logs <container>
```

