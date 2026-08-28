# Day 33 – Docker Compose: Multi-Container Basics

## Challenge Tasks

### Task 1: Install & Verify

Check whether Docker Compose is available:

```bash
docker compose version
```

Expected output:

```text
Docker Compose version v2.x.x
```

You can also verify Docker itself:

```bash
docker --version
```

Example:

```text
Docker version 28.x.x
```

---

## Task 2: Your First Compose File

### 1. Create the project folder

```bash
mkdir compose-basics
cd compose-basics
```

### 2. Create `docker-compose.yml`

```yaml
services:
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
```

### 3. Start the container

```bash
docker compose up
```

Or run it in detached mode:

```bash
docker compose up -d
```

### 4. Access Nginx

Open the following URL in your browser:

```text
http://localhost:8080
```

You should see the **Welcome to nginx!** page.

### 5. Stop and remove the container

```bash
docker compose down
```

---

# Task 3 — Two-Container Setup

Create a `docker-compose.yml` with WordPress and MySQL.

```yaml
services:
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - mysql_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db

volumes:
  mysql_data:
```

### Start the services

```bash
docker compose up -d
```

Check the running containers:

```bash
docker compose ps
```

Example:

```text
NAME                  SERVICE     STATUS
compose-basics-db-1   db          Up
compose-basics-wordpress-1 wordpress Up
```

### Access WordPress

Open:

```text
http://localhost:8080
```

Complete the WordPress installation in your browser.

### How WordPress connects to MySQL

The important configuration is:

```yaml
WORDPRESS_DB_HOST: db:3306
```

`db` is the **Compose service name**.

Docker Compose automatically creates a network for the services, allowing WordPress to resolve the MySQL container using:

```text
db
```

rather than an IP address.

### Verify Data Persistence

Stop and remove the containers:

```bash
docker compose down
```

Start them again:

```bash
docker compose up -d
```

Open:

```text
http://localhost:8080
```

The WordPress data should still be available because MySQL stores its data in the named volume:

```yaml
volumes:
  - mysql_data:/var/lib/mysql
```

The volume remains after:

```bash
docker compose down
```

You can verify it with:

```bash
docker volume ls
```

> Note: `docker compose down -v` removes the named volumes as well, so it should **not** be used when testing persistence.

---

# Task 4 — Compose Commands

## 1. Start services in detached mode

```bash
docker compose up -d
```

The `-d` flag runs the containers in the background.

---

## 2. View running services

```bash
docker compose ps
```

---

## 3. View logs of all services

```bash
docker compose logs
```

Follow the logs continuously:

```bash
docker compose logs -f
```

---

## 4. View logs of a specific service

For WordPress:

```bash
docker compose logs wordpress
```

Follow WordPress logs:

```bash
docker compose logs -f wordpress
```

For MySQL:

```bash
docker compose logs -f db
```

---

## 5. Stop services without removing them

```bash
docker compose stop
```

This stops the containers but does not remove them.

Start them again with:

```bash
docker compose start
```

---

## 6. Remove everything

Remove containers and the Compose network:

```bash
docker compose down
```

To also remove named volumes:

```bash
docker compose down -v
```

> Be careful with `-v` because it deletes persistent volume data.

---

## 7. Rebuild images

If the project contains a custom Dockerfile and changes are made to it, rebuild the image with:

```bash
docker compose build
```

Then start the services:

```bash
docker compose up -d
```

Or rebuild and start in one command:

```bash
docker compose up -d --build
```

---

# Task 5 — Environment Variables

## 1. Environment variables directly in `docker-compose.yml`

Example:

```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
      MYSQL_ROOT_PASSWORD: root_password

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
      WORDPRESS_DB_NAME: wordpress
```

---

## 2. Create a `.env` file

Create:

```text
.env
```

Add:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress_password
MYSQL_ROOT_PASSWORD=root_password
WORDPRESS_PORT=8080
```

---

## 3. Reference `.env` variables in `docker-compose.yml`

```yaml
services:
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "${WORDPRESS_PORT}:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
    depends_on:
      - db

volumes:
  mysql_data:
```

---

## Verify Environment Variables

Run:

```bash
docker compose config
```

This displays the final Compose configuration after variable substitution.

You can also check the environment inside the container:

```bash
docker compose exec db env
```

For WordPress:

```bash
docker compose exec wordpress env
```

Look for variables such as:

```text
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress_password
```

---

# Useful Docker Compose Commands

| Command                              | Purpose                                  |
| ------------------------------------ | ---------------------------------------- |
| `docker compose up`                  | Start services                           |
| `docker compose up -d`               | Start services in detached mode          |
| `docker compose down`                | Stop and remove containers/networks      |
| `docker compose stop`                | Stop containers without removing         |
| `docker compose start`               | Start stopped containers                 |
| `docker compose ps`                  | View service status                      |
| `docker compose logs`                | View logs                                |
| `docker compose logs -f`             | Follow logs                              |
| `docker compose logs wordpress`      | View WordPress logs                      |
| `docker compose exec wordpress bash` | Open shell inside WordPress              |
| `docker compose build`               | Build/rebuild images                     |
| `docker compose up -d --build`       | Rebuild and start                        |
| `docker compose config`              | Validate/render Compose configuration    |
| `docker compose down -v`             | Remove containers, networks, and volumes |

---

# Final Verification

Run:

```bash
docker compose up -d
```

Check the services:

```bash
docker compose ps
```

Check the logs:

```bash
docker compose logs -f
```

Open WordPress:

```text
http://localhost:8080
```

Stop the services:

```bash
docker compose stop
```

Start them again:

```bash
docker compose start
```

Finally, remove the containers and network:

```bash
docker compose down
```

The MySQL data remains because it is stored in the named volume:

```text
mysql_data
```

## What I Learned

* Docker Compose allows multiple containers to be managed from one YAML file.
* Compose automatically creates a network for services.
* Services can communicate using their Compose service names.
* Named volumes provide persistent storage.
* `.env` files can be used to manage configuration values.
* `docker compose up -d` runs services in the background.
* `docker compose down` removes containers and networks but keeps named volumes by default.
* `docker compose logs` is useful for troubleshooting services.
