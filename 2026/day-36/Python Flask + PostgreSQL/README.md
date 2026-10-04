### `Dockerfile`

 Your Dockerfile should:

 - Use a Python base image.
- Set a working directory.
- Copy `requirements.txt`.
- Install dependencies.
- Copy the application.
- Expose port `5000`.
- Start Flask.

 ### `docker-compose.yml`

 Your Compose file should have **two services**:

```
Flask App
    |
    v
PostgreSQL
```

 PostgreSQL should use:

```
Database: day36
Username: postgres
Password: postgres
```

 Your Flask container should connect using:

```
DATABASE_URL=postgresql://postgres:postgres@db:5432/day36
```

 Notice that the hostname is **`db`**, not `localhost`. Docker Compose provides DNS between services.

 You'll also need a PostgreSQL initialization mechanism so that this table exists:

```
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL
);
```

 Then start everything with:

```
docker compose up --build
```

 Test the application:

```
curl http://localhost:5000
```

 Health check:

```
curl http://localhost:5000/health
```

 Create a user:

```
curl -X POST http://localhost:5000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

 Get users:

```
curl http://localhost:5000/users
```
