# Day 32 – Docker Volumes & Networking

## Task 1: The Problem — Container Data

I used a PostgreSQL container for this task.

### Step 1: Run PostgreSQL

```bash
docker run --name my-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -d postgres
```

### Step 2: Create a database table and data

```bash
docker exec -it my-postgres psql -U postgres
```

Inside PostgreSQL:

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

SELECT * FROM users;
```

The data was successfully created.

### Step 3: Stop and remove the container

```bash
docker stop my-postgres
docker rm my-postgres
```

### Step 4: Run a new PostgreSQL container

```bash
docker run --name my-postgres-new \
  -e POSTGRES_PASSWORD=postgres \
  -d postgres
```

Checking the database:

```bash
docker exec -it my-postgres-new psql -U postgres
```

```sql
\dt
```

The `users` table was **not present**.

### What happened and why?

The data was lost because the PostgreSQL data was stored inside the original container's writable filesystem.

When the container was removed with:

```bash
docker rm my-postgres
```

its writable filesystem was also removed.

**Conclusion:** Containers are temporary by default. If database data needs to survive container deletion, it should be stored in a Docker volume or a bind mount.

---

# Task 2: Named Volumes

A named Docker volume can store database data independently of the container.

## Step 1: Create a named volume

```bash
docker volume create postgres-data
```

Verify it:

```bash
docker volume ls
```

Example:

```text
DRIVER    VOLUME NAME
local     postgres-data
```

## Step 2: Run PostgreSQL with the volume

```bash
docker run --name postgres-volume \
  -e POSTGRES_PASSWORD=postgres \
  -v postgres-data:/var/lib/postgresql/data \
  -d postgres
```

The volume is mounted at PostgreSQL's data directory.

## Step 3: Add data

```bash
docker exec -it postgres-volume psql -U postgres
```

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

SELECT * FROM users;
```

## Step 4: Stop and remove the container

```bash
docker stop postgres-volume
docker rm postgres-volume
```

The named volume was **not removed**.

## Step 5: Run a brand-new container using the same volume

```bash
docker run --name postgres-volume-new \
  -e POSTGRES_PASSWORD=postgres \
  -v postgres-data:/var/lib/postgresql/data \
  -d postgres
```

Check the data:

```bash
docker exec -it postgres-volume-new psql -U postgres
```

```sql
SELECT * FROM users;
```

The previous data is still present.

### Verify the volume

```bash
docker volume ls
```

```bash
docker volume inspect postgres-data
```

The inspection shows information such as the volume's name, driver, mount point, and creation information.

### Conclusion

**Yes, the data is still there.**

A named volume exists independently from the container. Removing the container does not remove the volume.

> **Container:** temporary
> **Named volume:** persistent storage

---

# Task 3: Bind Mounts

A bind mount connects a directory on the host machine directly to a directory inside the container.

## Step 1: Create a folder

```bash
mkdir -p ~/docker-nginx
cd ~/docker-nginx
```

Create an `index.html` file:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Docker Bind Mount</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This page is running from a bind mount.</p>
</body>
</html>
```

Save this as:

```text
~/docker-nginx/index.html
```

## Step 2: Run Nginx with a bind mount

```bash
docker run --name nginx-bind \
  -p 8080:80 \
  -v ~/docker-nginx:/usr/share/nginx/html \
  -d nginx
```

Open the following address in a browser:

```text
http://localhost:8080
```

The Nginx container displays the `index.html` file from the host machine.

## Step 3: Edit the HTML file

Change:

```html
<h1>Hello from Docker!</h1>
```

to:

```html
<h1>Hello from my updated Docker page!</h1>
```

Save the file and refresh the browser.

The updated page appears immediately because the container is directly using the host directory.

## Named Volume vs Bind Mount

| Feature                       | Named Volume                             | Bind Mount                             |
| ----------------------------- | ---------------------------------------- | -------------------------------------- |
| Managed by                    | Docker                                   | Host/user                              |
| Location                      | Docker-managed storage                   | Any host directory                     |
| Easy to share with containers | Yes                                      | Yes                                    |
| Host file access              | Not normally through a regular host path | Directly accessible                    |
| Common use                    | Database/application persistent data     | Development and configuration files    |
| Example                       | `postgres-data:/var/lib/postgresql/data` | `~/docker-nginx:/usr/share/nginx/html` |

### Conclusion

A **named volume** is managed by Docker and is usually preferred for persistent application/database data.

A **bind mount** maps a specific host directory into the container and is useful when the host needs to directly edit or access the files.

---

# Task 4: Docker Networking Basics

## Step 1: List Docker networks

```bash
docker network ls
```

Typical output includes:

```text
NETWORK ID     NAME      DRIVER    SCOPE
xxxxxx         bridge    bridge    local
xxxxxx         host      host      local
xxxxxx         none      null      local
```

## Step 2: Inspect the default bridge network

```bash
docker network inspect bridge
```

This displays information about the default bridge network, including connected containers, IP addresses, subnet configuration, and gateway.

## Step 3: Run two containers on the default bridge

```bash
docker run -d --name container1 alpine sleep 3600
docker run -d --name container2 alpine sleep 3600
```

Find their IP addresses:

```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container1
```

```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container2
```

## Can they ping each other by name?

Try:

```bash
docker exec container1 ping -c 3 container2
```

On the **default `bridge` network**, container-name DNS resolution is generally **not provided**.

Therefore, the containers cannot normally ping each other using `container2` as a hostname.

## Can they ping each other by IP?

Yes.

For example, if `container2` has IP `172.17.0.3`:

```bash
docker exec container1 ping -c 3 172.17.0.3
```

The ping should succeed while both containers are running on the same default bridge network.

### Conclusion

The default bridge network provides network connectivity between containers, but it does not provide the same automatic container-name DNS service that user-defined bridge networks provide.

---

# Task 5: Custom Networks

## Step 1: Create a custom bridge network

```bash
docker network create --driver bridge my-app-net
```

Verify:

```bash
docker network ls
```

## Step 2: Run two containers on the custom network

```bash
docker run -d \
  --name app1 \
  --network my-app-net \
  alpine sleep 3600
```

```bash
docker run -d \
  --name app2 \
  --network my-app-net \
  alpine sleep 3600
```

## Step 3: Ping by container name

From `app1`:

```bash
docker exec app1 ping -c 3 app2
```

This works.

The custom bridge network automatically provides DNS-based service discovery between containers.

### Why does custom networking allow name-based communication?

User-defined bridge networks have Docker's embedded DNS service. Docker can resolve container names to their IP addresses within that network.

For example:

```text
app1 ---> app2
         DNS resolves
         "app2" to its IP
```

The default `bridge` network does not provide this same automatic name-based service discovery.

### Conclusion

**Default bridge:**

```text
container1 ---> IP address ---> container2
```

**Custom bridge:**

```text
container1 ---> container2
       (Docker DNS)
```

Custom networks are therefore better for multi-container applications because containers can communicate using stable names rather than manually finding IP addresses.

---

# Task 6: Put It Together

For this task, I used PostgreSQL, a custom Docker network, a named volume, and an Alpine container as the application container.

## Step 1: Create a custom network

```bash
docker network create my-app-net
```

## Step 2: Create a named volume

```bash
docker volume create postgres-data
```

## Step 3: Run the PostgreSQL database

```bash
docker run -d \
  --name my-db \
  --network my-app-net \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=myapp \
  -v postgres-data:/var/lib/postgresql/data \
  postgres
```

The database now has:

* A persistent named volume
* A custom network
* The container name `my-db`

## Step 4: Run the application container

```bash
docker run -d \
  --name my-app \
  --network my-app-net \
  alpine sleep 3600
```

Both containers are connected to:

```text
my-app-net
```

## Step 5: Verify that the app can reach the database by name

From the application container:

```bash
docker exec my-app ping -c 3 my-db
```

The hostname `my-db` resolves to the PostgreSQL container's IP address.

To test the PostgreSQL port, install a network utility if necessary, or use a PostgreSQL client image:

```bash
docker run --rm \
  --network my-app-net \
  postgres \
  pg_isready -h my-db -U postgres
```

Expected result:

```text
my-db:5432 - accepting connections
```

This verifies that the application container can reach the database using the **container name** rather than an IP address.

---

# Overall Conclusions

| Task                               | Result                                                                                                         |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Container without volume           | Data disappears when container is removed                                                                      |
| Named volume                       | Data survives container removal                                                                                |
| Bind mount                         | Host files are directly available inside the container                                                         |
| Default bridge                     | Containers can communicate by IP, but name resolution is not automatically provided like user-defined networks |
| Custom bridge                      | Containers can communicate by container name                                                                   |
| Database + volume + custom network | Database data persists and other containers can reach it by name                                               |

## Key Docker Concepts

### 1. Containers are disposable

A container's writable filesystem should not be relied upon for important persistent data.

### 2. Volumes provide persistence

```bash
-v postgres-data:/var/lib/postgresql/data
```

The volume remains even after the container is deleted.

### 3. Bind mounts connect host files to containers

```bash
-v ~/docker-nginx:/usr/share/nginx/html
```

Changes made on the host are immediately visible inside the container.

### 4. Custom networks provide service discovery

```bash
docker network create my-app-net
```

Containers connected to the network can use container names to communicate.

### 5. A typical multi-container application

A common Docker setup looks like:

```text
                 my-app-net
        ┌──────────────────────────┐
        │                          │
        │   App Container          │
        │   my-app                 │
        │       │                  │
        │       │ my-db:5432       │
        │       ▼                  │
        │   Database Container     │
        │   my-db                  │
        │       │                  │
        └───────┼──────────────────┘
                │
                ▼
        Named Volume
        postgres-data
```

The **network** handles communication, while the **volume** handles persistent database storage.
