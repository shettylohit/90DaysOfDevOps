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


