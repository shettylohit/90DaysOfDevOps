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
