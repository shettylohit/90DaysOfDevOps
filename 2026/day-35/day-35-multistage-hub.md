# Day 35 – Multi-Stage Builds & Docker Hub


 # Task 1 – The Problem with Large Images

 I experimented with three simple applications:

 - Go
- Java
- Node.js

 The applications simply print `Hello, World!`.

---

 ## Go Application

 ### `main.go`

```
package main

import "fmt"

func main() {
	fmt.Println("Hello, World!")
}
```

 Run locally:

```
go run main.go
```

 ### Single-Stage Dockerfile

```
FROM golang:1.23-alpine

WORKDIR /app

COPY main.go .

CMD ["go", "run", "main.go"]
```

 Build the image:

```
docker build -t hello-go:single .
```

 Check the image size:

```
docker images hello-go:single
```

 This image contains the Go compiler and other build tools even though they are not required to run the compiled application.

---

 # Task 2 – Multi-Stage Build

 The application can be made much smaller by separating the build environment from the runtime environment.

 ### Multi-Stage Dockerfile

```
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY main.go .

RUN go build -o app main.go

FROM alpine:3.20

WORKDIR /app

COPY --from=builder /app/app .

CMD ["./app"]
```

 Build the image:

```
docker build -t hello-go:multi .
```

 Check the image size:

```
docker images hello-go:multi
```

 ### Comparison

 | Image | Purpose | Size |
| --- | --- | --- |
| `hello-go:single` | Build + runtime | Record using `docker images` |
| `hello-go:multi` | Runtime only | Record using `docker images` |

### Why is the multi-stage image smaller?

 The single-stage image contains the complete Go toolchain because the application is built and executed in the same container.

 The multi-stage build separates these responsibilities:

 1. The `builder` stage contains Go and compiles the application.
2. The final stage contains only Alpine and the compiled binary.
3. The Go compiler, source code, and build dependencies are not copied into the final image.

 Therefore, the final image contains only what is required to run the application.

---

 # Java Application

 ## `Main.java`

```
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

 Run locally:

```
javac Main.java
java Main
```

 ## Single-Stage Dockerfile

```
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

COPY Main.java .

RUN javac Main.java

CMD ["java", "Main"]
```

 Build:

```
docker build -t hello-java:single .
```

 Check size:

```
docker images hello-java:single
```

 ## Multi-Stage Dockerfile

```
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

COPY Main.java .

RUN javac Main.java

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/Main.class .

CMD ["java", "Main"]
```

 Build:

```
docker build -t hello-java:multi .
```

 Check size:

```
docker images hello-java:multi
```

 ### Why this is better

 The JDK is required to compile the application, but the JDK is not required to execute the compiled `.class` file.

 The final image therefore uses the smaller JRE image instead of the complete JDK.

---

 # Node.js Application

 ## `app.js`

```
console.log("Hello, World!");
```

 Run locally:

```
node app.js
```

 ## Single-Stage Dockerfile

```
FROM node:22-alpine

WORKDIR /app

COPY app.js .

CMD ["node", "app.js"]
```

 Build:

```
docker build -t hello-node:single .
```

 ## Multi-Stage Dockerfile

```
FROM node:22-alpine AS builder

WORKDIR /app

COPY app.js .

FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app/app.js .

CMD ["node", "app.js"]
```

 Build:

```
docker build -t hello-node:multi .
```

 ### Note

 For this particular Node.js application, the multi-stage build does not provide a meaningful size reduction because there are no dependencies or compilation steps.

 For a real Node.js application using TypeScript, React, Next.js, or another build system, multi-stage builds can be much more useful.

 For example, a build stage could run:

```
npm ci
npm run build
```

 and the final image could contain only the production dependencies and generated application files.

---

 # Task 3 – Docker Image Size Comparison

 The image sizes can be checked using:

```
docker images
```

 For a more focused comparison:

```
docker images hello-go
docker images hello-java
docker images hello-node
```

 Another useful command is:

```
docker image ls
```

 The important observation is that the final multi-stage image should contain only the runtime requirements rather than the complete build environment.

---

 # Task 4 – Docker Hub

 I tagged my Go multi-stage image for Docker Hub using the following repository:

```
lohitshetty/90days
```

 I used a version-specific tag:

```
docker tag hello-go:multi lohitshetty/90days:go-v2
```

 Then I pushed the image:

```
docker push lohitshetty/90days:go-v2
```

 ## Verify the Image

 The image can be pulled using:

```
docker pull lohitshetty/90days:go-v2
```

 Run it:

```
docker run --rm lohitshetty/90days:go-v2
```

 Expected output:

```
Hello, World!
```

---

 # Docker Hub Repository

 Docker Hub repository:

 **`lohitshetty/90days`**

 The repository contains the pushed Docker image and its tags.

 ## Tags

 The image was published using:

```
go-v2
```

 Tags are useful for identifying different versions of an image.

 For example:

```
go-v1
go-v2
go-v3
latest
```

 A specific version can be pulled with:

```
docker pull lohitshetty/90days:go-v2
```

 If an image is tagged as `latest`, it can be pulled with:

```
docker pull lohitshetty/90days:latest
```

 `latest` does not automatically mean "newest image". It is simply a tag name. The maintainer must explicitly tag and push an image as `latest`.

 Using version-specific tags makes deployments more predictable because a deployment can reference a known version.

---

 # Task 5 – Image Best Practices

 I also reviewed several Docker image best practices.

 ## 1\. Use Minimal Base Images

 Instead of using a large general-purpose image such as Ubuntu, use a smaller runtime image when possible.

 For example:

```
FROM alpine:3.20
```

 instead of:

```
FROM ubuntu:24.04
```

 For Go applications, an even smaller option can be a `scratch` image when the application does not require additional runtime libraries.

 Example:

```
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY main.go .

RUN CGO_ENABLED=0 go build -o app main.go

FROM scratch

COPY --from=builder /app/app /app

ENTRYPOINT ["/app"]
```

 The `scratch` image contains virtually nothing except the application copied into it.

---

 ## 2\. Don't Run Containers as Root

 A container should run with the minimum privileges required.

 For Alpine-based images, a non-root user can be created:

```
FROM alpine:3.20

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/app .

USER appuser

CMD ["./app"]
```

 Running as a non-root user reduces the impact of a potential application compromise.

---

 ## 3\. Use Specific Base Image Tags

 Avoid:

```
FROM alpine:latest
```

 Prefer:

```
FROM alpine:3.20
```

 Using an explicit version makes builds more predictable and reduces the chance of unexpected changes when the base image is updated.

---

 ## 4\. Reduce Unnecessary Layers

 Where appropriate, related commands can be combined:

```
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
```

 This keeps the Dockerfile clean and avoids creating unnecessary layers.

 However, readability should still be considered. Combining every command into one large `RUN` instruction is not always better.

---

 ## 5\. Use `.dockerignore`

 A `.dockerignore` file prevents unnecessary files from being sent to the Docker build context.

 Example:

```
.git
.gitignore
README.md
*.log
node_modules
.env
```

 This can improve build performance and prevent sensitive or unnecessary files from being copied into images.

---

 # Final Go Dockerfile

 The improved Go Dockerfile combines the main best practices:

```
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY main.go .

RUN CGO_ENABLED=0 go build -o app main.go

FROM alpine:3.20

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/app .

USER appuser

ENTRYPOINT ["./app"]
```

 Build:

```
docker build -t hello-go:secure .
```

 Run:

```
docker run --rm hello-go:secure
```

 Expected output:

```
Hello, World!
```

---

 # Useful Docker Commands

 ## Build an image

```
docker build -t hello-go:multi .
```

 ## List images

```
docker images
```

 ## Inspect image size

```
docker image ls
```

 ## Run an image

```
docker run --rm hello-go:multi
```

 ## Tag an image

```
docker tag hello-go:multi lohitshetty/90days:go-v2
```

 ## Login to Docker Hub

```
docker login
```

 ## Push an image

```
docker push lohitshetty/90days:go-v2
```

 ## Pull an image

```
docker pull lohitshetty/90days:go-v2
```

 ## Remove a local image

```
docker rmi lohitshetty/90days:go-v2
```

 ## Pull again from Docker Hub

```
docker pull lohitshetty/90days:go-v2
```

---



 Your Docker Hub repository can be opened here:

 Docker Hub — lohitshetty/90days

 For the GitHub submission, save the artifact exactly as **`2026/day-35/day-35-multistage-hub.md`**.
