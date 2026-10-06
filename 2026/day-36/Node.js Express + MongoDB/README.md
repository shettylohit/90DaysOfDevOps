Project structure
```
express-task-manager/
│
├── server.js
├── package.json
├── .env
│
├── models/
│   └── Task.js
│
└── public/
    ├── index.html
    └── style.css

```

Run it
First make sure MongoDB is running.

Then:
```
cd express-task-manager
npm install
npm run dev
```
Open:
```
http://localhost:3000
```

This one is more interesting because MongoDB should be a separate container.
```
                         Docker Host
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   ┌──────────────────────┐                              │
│   │   Express Container  │                              │
│   │                      │                              │
│   │   Node.js            │                              │
│   │   Express API        │                              │
│   │   Frontend           │                              │
│   │                      │                              │
│   │       Port 3000      │                              │
│   └──────────┬───────────┘                              │
│              │                                          │
│              │ MongoDB connection                       │
│              │ mongodb://mongodb:27017/taskmanager      │
│              ▼                                          │
│   ┌──────────────────────┐                              │
│   │   MongoDB Container  │                              │
│   │                      │                              │
│   │      MongoDB         │                              │
│   │                      │                              │
│   │       Port 27017     │                              │
│   └──────────┬───────────┘                              │
│              │                                          │
│              ▼                                          │
│       ┌───────────────┐                                 │
│       │ Docker Volume │                                 │
│       │ MongoDB Data  │                                 │
│       └───────────────┘                                 │
│                                                         │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
                        Browser
                     localhost:3000
```
The important concept
You now have two containers:
```
┌─────────────────┐
│ Express         │
│ Container       │
│                 │
│ Node.js         │
│ Express         │
└────────┬────────┘
         │
         │ Docker Network
         │
         ▼
┌─────────────────┐
│ MongoDB         │
│ Container       │
│                 │
│ MongoDB         │
└────────┬────────┘
         │
         ▼
    Docker Volume
```
The Express container doesn't connect to localhost for MongoDB.

Instead, Docker provides a network between the containers.

Conceptually:
```
Express
   │
   │
   └──────► mongodb:27017
                  │
                  ▼
              MongoDB
```
So your application configuration changes from something like:
```
localhost:27017
```
to:
```
mongodb:27017
```
where mongodb is the MongoDB container/service name.



# Docker and Docker compose Steps 

Use the following commands 

to create a docker network 
```
docker network create node-app-network 
```

Create a mongodb container 

```
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -v mongodb-data:/data/db \
  --network node-app-network \
  mongo:7
```

Change the name of the Mongo URI to Mongodb container name 

```
docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                             NAMES
34601453db8b   mongo:7   "docker-entrypoint.s…"   5 seconds ago   Up 3 seconds   0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp   mongodb
```

```
MONGO_URI=mongodb:mongodb:27017/taskmanager
```
Build the image using the docker file 

Run npm install if there is no package-lock.json file or elese the docker build will fail
```
docker build -t node:v1 .
```

Create the application container using docker image 
```
docker run -p 3000:3000 \
  --env-file .env \
  --network node-app-network \
  node:v1
```


Perfect. Since your **Node.js + MongoDB project is already working**, now Dockerize it incrementally. I won't give you the Dockerfile or Compose code.

 ## Your goal

 You currently have:

```
Ubuntu EC2
│
├── Node.js / Express
│      │
│      ▼
│   MongoDB
│      │
│      └── Docker container
│
└── Browser
```

 You want to reach:

```
                 Docker
┌─────────────────────────────────────┐
│                                     │
│  ┌─────────────────┐                │
│  │ Node.js         │                │
│  │ Express         │                │
│  │ Container       │                │
│  └────────┬────────┘                │
│           │                         │
│           │ Docker Network          │
│           ▼                         │
│  ┌─────────────────┐                │
│  │ MongoDB         │                │
│  │ Container       │                │
│  └────────┬────────┘                │
│           │                         │
│           ▼                         │
│      Docker Volume                  │
│                                     │
└─────────────────────────────────────┘
```

 # Step 1 — Understand what needs to be containerized

 You have two processes:

```
1. Node.js + Express
2. MongoDB
```

 Therefore:

```
Node.js     → Container
MongoDB     → Container
```

 Don't put both into one container.

---

 # Step 2 — Create a Dockerfile for Node.js

 Inside your project:

```
express-task-manager/
│
├── Dockerfile          ← you create this
├── server.js
├── package.json
├── package-lock.json
├── .env
├── models/
└── public/
```

 Your Dockerfile needs to describe:

 1. Which Node.js base image to use
2. Working directory inside the container
3. Copy `package.json`
4. Install dependencies
5. Copy your application files
6. Tell Docker which port the application uses
7. Tell the container how to start your application

 **Don't worry about MongoDB in this Dockerfile.** MongoDB gets its own container.

---

 # Step 3 — Think about `.dockerignore`

 Create:

```
.dockerignore
```

 Think about which files/directories **should not be copied into the image**.

 For example, you don't want to unnecessarily copy:

```
node_modules/
.git/
.env
```

 Think carefully about `.env`.

 Your application needs configuration, but you generally don't want secrets baked permanently into a Docker image.

---

 # Step 4 — Build the Node.js image

 Once your Dockerfile is ready, build an image.

 The mental model is:

```
Dockerfile
    │
    │ docker build
    ▼
Docker Image
    │
    │ docker run
    ▼
Node.js Container
```

 Give your image a meaningful name, for example:

```
task-manager-app
```

---

 # Step 5 — Run the Node container

 Run the container and map:

```
Host port 3000
       ↓
Container port 3000
```

 So the flow becomes:

```
Browser
   │
   ▼
EC2 :3000
   │
   ▼
Node Container :3000
```

 At this point, **don't worry about MongoDB yet**.

---

 # Step 6 — Understand the MongoDB problem

 This is the most important part.

 Your current `.env` says:

```
127.0.0.1:27017
```

 That worked when:

```
Node.js → Ubuntu localhost → MongoDB container
```

 But after Node.js itself is inside a container:

```
Node Container
      │
      │ 127.0.0.1
      ▼
Node Container itself
```

 It will **not** reach MongoDB.

 Remember:

 > `localhost` inside a container means that container itself.

---

 # Step 7 — Create a Docker network

 You need a network that both containers join.

 Conceptually:

```
                 Docker Network
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
      Node Container    MongoDB Container
```

 Create a custom Docker network.

 For example, conceptually:

```
task-network
```

 Then both containers should be connected to it.

---

 # Step 8 — Run MongoDB on that network

 You already know how to run MongoDB as a container.

 Now run it attached to your new Docker network.

 Give the MongoDB container a recognizable name, such as:

```
mongodb
```

 Now Docker's internal DNS lets the Node container find MongoDB using:

```
mongodb
```

 instead of:

```
127.0.0.1
```

---

 # Step 9 — Change your MongoDB connection

 This is the key change.

 ### Before

 Your Node application was:

```
Node
 │
 └── 127.0.0.1:27017
          │
          ▼
       MongoDB
```

 ### After

 It should become:

```
Node Container
      │
      │ mongodb:27017
      ▼
MongoDB Container
```

 So change your `.env` configuration accordingly.

 The important concept is:

```
mongodb://<container-name>:27017/<database>
```

 Don't use the MongoDB container's IP address.

 Don't use `localhost`.

 Use its Docker/container name.

---

 # Step 10 — MongoDB needs persistent storage

 Containers are disposable.

 If you remove:

```
MongoDB Container
```

 you don't want your tasks to disappear.

 So create a **Docker volume**:

```
MongoDB Container
       │
       ▼
┌─────────────────┐
│ Docker Volume   │
│                 │
│ MongoDB data    │
└─────────────────┘
```

 Your architecture becomes:

```
Node Container
      │
      │ Docker Network
      ▼
MongoDB Container
      │
      ▼
MongoDB Volume
```

---

 # Step 11 — Test container-to-container communication

 Before testing the browser, verify:

```
Node Container
      │
      │
      ▼
MongoDB Container
```

 You should verify:

 1. Both containers are running.
2. Both are attached to the same Docker network.
3. MongoDB is listening on `27017`.
4. Node can resolve the MongoDB container name.
5. Node can connect to MongoDB.
6. Your application logs say:

```
MongoDB connected
```

---

 # Step 12 — Test the application

 Once both containers are running:

```
Browser
   │
   ▼
EC2 public IP :3000
   │
   ▼
Node Container
   │
   ▼
MongoDB Container
```

 Open:

```
http://YOUR_EC2_PUBLIC_IP:3000
```

 Then test:

 - Create task
- View tasks
- Complete task
- Undo task
- Delete task

---

 # Step 13 — Test persistence

 This is an important Docker exercise.

 Create a task:

```
Learn Docker
```

 Then stop/remove the MongoDB container.

 Start a new MongoDB container using the **same volume**.

 Check your application again.

 Your task should still exist.

 That proves your volume is working.

---

 # Step 14 — Only after everything works, use Docker Compose

 Once you understand:

```
Dockerfile
Image
Container
Network
Volume
Port mapping
Environment variables
```

 then move to:

```
Docker Compose
```

 Compose will allow you to describe:

```
                Compose
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
  Node Service          MongoDB Service
        │                     │
        └─────────┬───────────┘
                  │
             Docker Network
                  │
             MongoDB Volume
```

 You originally asked me **not to give you Docker or Compose files**, so I won't.

---

 ## Your checklist

 Work through this in order:

```
☐ 1. Create Dockerfile
☐ 2. Create .dockerignore
☐ 3. Build Node.js image
☐ 4. Run Node container
☐ 5. Create Docker network
☐ 6. Run MongoDB container on that network
☐ 7. Create MongoDB volume
☐ 8. Change MONGO_URI from localhost to MongoDB container name
☐ 9. Pass environment configuration to Node container
☐ 10. Connect Node → MongoDB
☐ 11. Map port 3000
☐ 12. Test application from browser
☐ 13. Test MongoDB persistence
☐ 14. Understand everything
☐ 15. Then create Docker Compose setup
```

 ### The three things I especially want you to understand

```
             Dockerized App

        ┌──────────────────┐
        │ Node Container   │
        │                  │
        │ Express          │
        └────────┬─────────┘
                 │
                 │ 1. NETWORK
                 │
                 ▼
        ┌──────────────────┐
        │ Mongo Container  │
        │                  │
        │ MongoDB          │
        └────────┬─────────┘
                 │
                 │ 2. VOLUME
                 ▼
        ┌──────────────────┐
        │ Persistent Data  │
        └──────────────────┘

        3. PORT
        Browser ──► Node :3000
```

 If you build it yourself in that order, you'll actually **learn Docker**, rather than just copying a `Dockerfile` and `docker-compose.yml`.
