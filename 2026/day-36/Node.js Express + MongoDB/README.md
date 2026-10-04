Your Compose setup should have:

```
Node.js app
     |
     v
  MongoDB
```

 The Node.js container should connect to MongoDB using an environment variable such as:

```
MONGO_URI=mongodb://mongo:27017/day36
```

 Then test:

```
docker compose up --build
```

 And visit:

```
http://localhost:3000
```

 Once you've written your Dockerfile and `docker-compose.yml`, send them to me and I'll review them like an actual code review rather than giving you the solution upfront.
