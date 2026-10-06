FROM node:22-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]





docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -v mongodb-data:/data/db \
  mongo:7


 ### Mistakes / improvements

 1. **`127.0.0.1` is wrong for MongoDB inside the Node container**
   - Your `.env` still has:

     ```
     mongodb://127.0.0.1:27017/taskmanager
     ```
   - Inside the Node container, `127.0.0.1` means **the Node container itself**, not your MongoDB container.
2. **Your Node and MongoDB containers need to be on the same Docker network**
   - Create a dedicated Docker network.
   - Attach both containers to it.
3. **Use the MongoDB container/service name as the hostname**
   - Once they're on the same network, Node should communicate with MongoDB using the MongoDB container's **name**, not its IP address and not `localhost`.
4. **Your MongoDB container needs to be running**
   - Check:

     ```
     docker ps
     ```
   - Make sure MongoDB shows `Up`, not `Exited`.
5. **Your Node container needs the correct environment variables**
   - Your `.env` exists on the host, but you need to think about how those values get into the container.
   - Don't assume the host's `.env` is automatically available inside the image/container.
6. **Don't hard-code environment configuration into the Dockerfile**
   - Keep application configuration separate from the image.
   - Think about passing environment variables when starting the container.
7. **Your `EXPOSE 3000` is fine, but remember what it does**
   - `EXPOSE 3000` documents the container port.
   - `-p 3000:3000` is what actually publishes it to the host.
8. **Your application should listen on `0.0.0.0`**
   - You've already tested the app directly on the EC2 machine.
   - Inside a container, make sure Express isn't only listening on `localhost`.
   - Otherwise the application can be running but inaccessible through the published port.
9. **`npm run dev` is not ideal for a production container**
   - `node --watch` is primarily a development workflow.
   - For your learning project it's okay initially, but later create a production-oriented container that uses your normal `start` script.

12. **Think about `node_modules`**
    - Make sure your `.dockerignore` prevents your host's `node_modules` from being copied into the image.
    - The container should install its own dependencies.

---

 ### Your current architecture

 Right now you effectively have:

```
EC2
│
├── Node Container
│      │
│      └── 127.0.0.1:27017  ❌
│
└── MongoDB Container
       │
       └── 27017
```

 You need to get to:

```
                 Docker Network
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
      Node Container     MongoDB Container
             │                 │
             │                 ▼
             │          MongoDB Volume
             │
             ▼
        Host :3000
             │
             ▼
          Browser
```

 ### Your biggest mistake right now

 **Don't change the Dockerfile first.**

 Your Dockerfile is successfully starting Node. The immediate problem is understanding **Docker networking and environment variables**.

 Focus on these three concepts next:

```
1. Docker Network
       ↓
2. Container name as hostname
       ↓
3. MONGO_URI passed into Node container
```

 Once you fix those, your `MongoDB connection error: ECONNREFUSED 127.0.0.1:27017` should disappear.