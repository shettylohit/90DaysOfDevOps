
### Go

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello, World!")
}
```

Run it with:

```bash
go run main.go
```

Docker file for go app
```
FROM golang:1.23-alpine

WORKDIR /app

COPY main.go .

CMD ["go", "run", "main.go"]

```


### Java

```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

Run it with:

```bash
javac Main.java
java Main
```
Docker file for java app

```
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
COPY Main.java .
RUN javac Main.java
CMD ["java", "Main"]
```

### Node.js

```javascript
console.log("Hello, World!");
```

Run it with:

```bash
node app.js
```
Dockerfile for nodejs
```
FROM node:22-alpine
WORKDIR /app
COPY app.js .
CMD ["node", "app.js"]
```
