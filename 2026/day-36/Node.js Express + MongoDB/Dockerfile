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



docker run -p 3000:3000 --env-file .env my-image-name # docker command to pass .env file during docker run

 ### Mistakes / improvements

 



8. **Your application should listen on `0.0.0.0`**
   - You've already tested the app directly on the EC2 machine.
   - Inside a container, make sure Express isn't only listening on `localhost`.
   - Otherwise the application can be running but inaccessible through the published port.


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