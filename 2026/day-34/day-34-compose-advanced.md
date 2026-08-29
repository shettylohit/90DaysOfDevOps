# Docker Compose 3-Service App Stack

This project demonstrates a simple **Flask + PostgreSQL + Redis** application stack using Docker Compose.

## Stack

* **Web app:** Python Flask
* **Database:** PostgreSQL
* **Cache:** Redis
* **Container orchestration:** Docker Compose

---

# Project Structure

```text
docker-compose-demo/
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── app.py
└── README.md
```

---

# Task 1: Build Your Own App Stack

## `app.py`

The Flask application connects to PostgreSQL and Redis.

```python
from flask import Flask
import os
import psycopg2
import redis

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        database=os.getenv("POSTGRES_DB", "appdb"),
        user=os.getenv("POSTGRES_USER", "appuser"),
        password=os.getenv("POSTGRES_PASSWORD", "apppassword"),
    )


@app.route("/")
def home():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]
        cur.close()
        conn.close()

        return f"""
        <h1>Hello from Flask!</h1>
        <p>Database connection successful.</p>
        <p>PostgreSQL: {db_version}</p>
        """

    except Exception as e:
        return f"Database connection failed: {e}", 500


@app.route("/cache")
def cache():
    try:
        r = redis.Redis(
            host=os.getenv("REDIS_HOST", "redis"),
            port=6379,
            decode_responses=True
        )

        r.set("message", "Hello from Redis!")
        value = r.get("message")

        return f"<h1>Redis</h1><p>{value}</p>"

    except Exception as e:
        return f"Redis connection failed: {e}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

The important point is that the application uses the **service names** `db` and `redis` as hostnames. Docker Compose provides DNS resolution between containers on the same network.

---

## `requirements.txt`

```text
Flask==3.1.0
psycopg2-binary==2.9.10
redis==5.2.1
```

---

## Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

## `docker-compose.yml`

```yaml
services:

  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      DB_HOST: db
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
      REDIS_HOST: redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    labels:
      app.name: flask-web
      app.component: web
      app.environment: development
    restart: unless-stopped

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 10s
    networks:
      - app-network
    labels:
      app.name: postgres
      app.component: database
      app.environment: development
    restart: always

  redis:
    image: redis:7-alpine
    networks:
      - app-network
    labels:
      app.name: redis
      app.component: cache
      app.environment: development
    restart: unless-stopped


networks:
  app-network:
    driver: bridge


volumes:
  postgres-data:
```

---

# Task 2: `depends_on` & Healthchecks

The database has a healthcheck:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
  interval: 5s
  timeout: 5s
  retries: 5
  start_period: 10s
```

The Flask application depends on the database being healthy:

```yaml
depends_on:
  db:
    condition: service_healthy
```

This is better than simply writing:

```yaml
depends_on:
  - db
```

The basic `depends_on` only controls startup order. It does **not** necessarily mean that PostgreSQL is ready to accept connections.

With:

```yaml
condition: service_healthy
```

Docker Compose waits for the database healthcheck to report `healthy` before starting the web application.

## Test

First bring the stack down:

```bash
docker compose down
```

Start it again:

```bash
docker compose up
```

Or run in the background:

```bash
docker compose up -d
```

Check the containers:

```bash
docker compose ps
```

You should see PostgreSQL eventually become:

```text
healthy
```

The web container is then started after the database passes its healthcheck.

You can also inspect the database health status:

```bash
docker inspect $(docker compose ps -q db) \
  --format '{{.State.Health.Status}}'
```

Expected result:

```text
healthy
```

---

# Task 3: Restart Policies

The PostgreSQL service uses:

```yaml
restart: always
```

## Test `restart: always`

Start the stack:

```bash
docker compose up -d
```

Find the database container:

```bash
docker compose ps
```

Manually kill it:

```bash
docker inspect python_app-db-1 --format '{{.State.Pid}} 
```
This command will give the Pid id of the db container
```bash
sudo kill -9 <pid>
```
Check the containers again:

```bash
docker compose ps
```

The database container should be restarted automatically.

You can also watch the containers:

```bash
watch docker compose ps
```

---

## Try `restart: on-failure`

Change:

```yaml
restart: always
```

to:

```yaml
restart: on-failure
```

Then recreate the service:

```bash
docker compose up -d --force-recreate db
```

### Difference

| Policy           | Behavior                                                               |
| ---------------- | ---------------------------------------------------------------------- |
| `no`             | Never automatically restart the container.                             |
| `always`         | Always restart the container when it stops, regardless of exit status. |
| `on-failure`     | Restart when the container exits with a non-zero exit code.            |
| `unless-stopped` | Restart automatically unless the container was explicitly stopped.     |

### When would I use each?

**`restart: always`**

Useful for important infrastructure such as databases or services that should continuously run.

Example:

```yaml
restart: always
```

**`restart: on-failure`**

Useful for applications or jobs where a crash should cause a restart, but a clean exit should not.

Example:

```yaml
restart: on-failure
```

**`restart: unless-stopped`**

Useful for long-running development or production services where I want automatic recovery but still want an explicit manual stop to persist.

**`restart: no`**

Useful when debugging or for short-lived containers where automatic restarts are undesirable.

---

# Task 4: Custom Dockerfiles in Compose

Instead of using a pre-built Flask image, the web service uses:

```yaml
build:
  context: .
  dockerfile: Dockerfile
```

This tells Docker Compose to build the application from the local `Dockerfile`.

## Build and start

```bash
docker compose up --build -d
```

The `--build` option rebuilds the web image before starting the services.

## Make a code change

For example, change:

```python
return f"""
<h1>Hello from Flask!</h1>
```

to:

```python
return f"""
<h1>Hello from My Docker Compose App!</h1>
```

Then rebuild and restart:

```bash
docker compose up --build -d
```

The updated application is now running.

## View logs

```bash
docker compose logs -f web
```

---

# Task 5: Named Networks & Volumes

## Named Network

The Compose file explicitly defines:

```yaml
networks:
  app-network:
    driver: bridge
```

Each service is connected to it:

```yaml
networks:
  - app-network
```

This allows the containers to communicate using their Compose service names.

For example:

```text
web -> db
web -> redis
```

The Flask application can therefore connect to PostgreSQL using:

```text
db
```

and Redis using:

```text
redis
```

---

## Named Volume

PostgreSQL uses:

```yaml
volumes:
  - postgres-data:/var/lib/postgresql/data
```

The volume is defined at the bottom of the Compose file:

```yaml
volumes:
  postgres-data:
```

This means PostgreSQL data persists even if the database container is removed.

List volumes:

```bash
docker volume ls
```

Inspect the volume:

```bash
docker volume inspect docker-compose-demo_postgres-data
```

The exact volume name may differ depending on the Compose project name.

### Important

Running:

```bash
docker compose down
```

does **not** normally remove named volumes.

To remove the database volume as well:

```bash
docker compose down -v
```

This will delete the PostgreSQL data stored in the named volume.

---

## Labels

Labels have been added to each service:

```yaml
labels:
  app.name: postgres
  app.component: database
  app.environment: development
```

Labels are useful for organizing and identifying containers.

For example:

```bash
docker ps --filter "label=app.component=database"
```

---

# Task 6: Scaling — Bonus

Try scaling the web application:

```bash
docker compose up -d --scale web=3
```

Check the running containers:

```bash
docker compose ps
```

You will get three web containers.

However, there is a problem.

The Compose file contains:

```yaml
ports:
  - "5000:5000"
```

All three web containers are trying to bind their container port `5000` to the **same host port `5000`**.

Only one container can normally bind to host port `5000`.

Therefore, scaling the service with a fixed host port causes a port conflict.

You may see an error similar to:

```text
Bind for 0.0.0.0:5000 failed: port is already allocated
```

## Why doesn't simple scaling work with port mapping?

This mapping:

```yaml
ports:
  - "5000:5000"
```

means:

```text
HOST PORT 5000 -> CONTAINER PORT 5000
```

When three containers are created, Docker would need to perform:

```text
Host:5000 -> web-1:5000
Host:5000 -> web-2:5000
Host:5000 -> web-3:5000
```

The host cannot have three different containers simultaneously claiming the same host port.

### Better architecture

For real scaling, the web containers should normally sit behind a **reverse proxy/load balancer**, such as Nginx, Traefik, or another ingress/load-balancing solution.

The architecture would look like:

```text
                 ┌──────────────┐
                 │    Client    │
                 └──────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │ Reverse Proxy │
                │ / Load Balancer│
                └───────┬───────┘
                        │
              ┌─────────┼─────────┐
              │         │         │
              ▼         ▼         ▼
           web-1     web-2     web-3
              │         │         │
              └─────────┼─────────┘
                        │
                 ┌──────┴──────┐
                 │ PostgreSQL  │
                 └─────────────┘
```

The reverse proxy exposes one host port and distributes requests among the web containers.

---

# Useful Docker Commands

## Start everything

```bash
docker compose up -d
```

## Build and start

```bash
docker compose up --build -d
```

## View services

```bash
docker compose ps
```

## View logs

```bash
docker compose logs
```

Web logs only:

```bash
docker compose logs -f web
```

Database logs only:

```bash
docker compose logs -f db
```

## Stop the stack

```bash
docker compose down
```

## Stop and remove volumes

```bash
docker compose down -v
```

## Rebuild the web application

```bash
docker compose up --build -d web
```

## Scale the web service

```bash
docker compose up -d --scale web=3
```

---

# Testing the Application

After starting the stack:

```bash
docker compose up --build -d
```

Open:

```text
http://localhost:5000
```

The page should show that the Flask application successfully connected to PostgreSQL.

Test Redis at:

```text
http://localhost:5000/cache
```

Expected response:

```text
Redis
Hello from Redis!
```

---

# Final `docker-compose.yml`

The complete Compose file is:

```yaml
services:

  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      DB_HOST: db
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
      REDIS_HOST: redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    labels:
      app.name: flask-web
      app.component: web
      app.environment: development
    restart: unless-stopped

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 10s
    networks:
      - app-network
    labels:
      app.name: postgres
      app.component: database
      app.environment: development
    restart: always

  redis:
    image: redis:7-alpine
    networks:
      - app-network
    labels:
      app.name: redis
      app.component: cache
      app.environment: development
    restart: unless-stopped

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:
```

---

# Task Summary

| Task                   | Implementation                             |
| ---------------------- | ------------------------------------------ |
| 1. Three-service stack | Flask + PostgreSQL + Redis                 |
| 1. Dockerfile          | Python 3.12 + Flask dependencies           |
| 2. `depends_on`        | Web depends on DB                          |
| 2. Healthcheck         | `pg_isready` checks PostgreSQL             |
| 2. `service_healthy`   | Web waits for healthy DB                   |
| 3. Restart policy      | Database uses `restart: always`            |
| 3. `on-failure`        | Restarts only after failure/non-zero exit  |
| 4. Custom build        | Web uses local Dockerfile                  |
| 4. Rebuild             | `docker compose up --build -d`             |
| 5. Network             | Explicit `app-network`                     |
| 5. Volume              | Named `postgres-data` volume               |
| 5. Labels              | Added to all services                      |
| 6. Scaling             | `docker compose up --scale web=3`          |
| 6. Scaling issue       | Fixed host port `5000` causes conflicts    |
| 6. Solution            | Use a reverse proxy/load balancer          |
| 7. Application test    | `/` tests PostgreSQL, `/cache` tests Redis |

# Conclusion

This stack demonstrates the main Docker Compose concepts:

1. **Services** define the application containers.
2. **`build`** allows the Flask application to use a custom Dockerfile.
3. **`depends_on` + healthcheck** ensures the web application waits for PostgreSQL to become ready.
4. **Restart policies** control how Docker handles stopped or crashed containers.
5. **Named networks** provide predictable service-to-service communication.
6. **Named volumes** preserve PostgreSQL data.
7. **Labels** help organize and identify containers.
8. **Scaling** is possible, but fixed host-port mappings prevent multiple replicas from using the same host port directly.
