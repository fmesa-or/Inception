*This project has been created as part of the 42 curriculum by fmesa-or.*

# DEV_DOC — Developer Documentation

This document explains how to set up the environment from scratch, build and run the project,
manage containers and volumes, and understand where and how data is persisted.

---

## 1. Prerequisites

- A virtual machine running **Debian 12**.
- **Docker Engine** installed (do not use the `docker.io` package from the Debian repositories —
  use Docker's official repository to obtain the `docker compose` v2 plugin).
- The **Docker Compose plugin** available (`docker compose version` must work).
- Permission to write to `/home/fmesa-or/data` (or the user must belong to the `docker` group
  or have root privileges to avoid permission issues with bind mounts).
- The domain `fmesa-or.42.fr` pointing to `127.0.0.1` in the host machine's `/etc/hosts`.

### Docker Installation (summary — see Readme.md for the complete guide)

```bash
sudo apt update && sudo apt upgrade
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker
```

---

## 2. Environment Setup

### 2.1 Clone the repository and enter the project directory

```bash
git clone <repo-url>
cd inception
```

### 2.2 Environment Variables File (`.env`)

The project **will not work without this file**, and for security reasons it is not tracked by Git.
It must be created manually as `srcs/.env` with at least the following variables:

```dotenv
# Domain
DOMAIN_NAME=fmesa-or.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_ROOT_PASSWORD=<root_password>
SQL_USER=<wordpress_db_user>
SQL_PASS=<wordpress_db_user_password>

# WordPress
WORDPRESS_DB_HOST=mariadb
WP_ADMIN_USER=<admin_username>       # Must NOT contain admin/Admin/administrator/Administrator
WP_ADMIN_PASS=<admin_password>
WP_SECOND_USER=<secondary_username>
WP_SECOND_PASS=<secondary_password>
```

> All credentials are stored exclusively in this file. Dockerfiles and
> `docker-compose.yml` only reference variable names, never hardcoded values.

### 2.3 Local Domain

Add the following entry to the host machine's `/etc/hosts` file:

```
127.0.0.1   fmesa-or.42.fr
```

---

## 3. Building and Running with the Makefile

All targets internally invoke:

```bash
docker compose -f ./srcs/docker-compose.yml ...
```

| Target | Description |
|---|---|
| `make build` | Creates the host data directories and starts all three services while forcing image rebuilds. |
| `make up` | Starts the services without rebuilding the images. |
| `make down` | Stops and removes the containers while preserving all data. |
| `make downv` | Same as `down`, but also removes the named volumes. |
| `make start` / `make stop` | Starts or stops already-created containers without recreating them. |
| `make show` | Lists containers, images and volumes. |
| `make db` | Starts only the `mariadb` service in detached mode (useful for testing the database independently). |
| `make rm-all` | Aggressively cleans Docker by removing every container, image and volume on the machine (not only those belonging to this project). |
| `make fclean` | Executes `rm-all` and removes `/home/fmesa-or/data` from the host machine. |
| `make help` | Displays this table in the terminal. |

Typical development workflow:

```bash
make build          # First build or after modifying Dockerfiles
# ... work, inspect logs ...
make down           # Stop without losing data
make up             # Start again
```

If something becomes corrupted (damaged database, inconsistent `wp-config.php`, etc.),
the clean way to start over is:

```bash
make downv
make build
```

---

## 4. Project Structure and Responsibility of Each Dockerfile

```text
inception/
├── docs/
│   └── en.subject.pdf
├── srcs/
│   ├── .env                          # Not tracked — credentials
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile            # FROM debian:12 + installs mariadb-server
│       │   ├── entrypoint.sh         # Initializes the database, creates the DB/user and starts mysqld as PID 1
│       │   └── conf/50-server.cnf    # bind-address 0.0.0.0, port 3306
│       ├── nginx/
│       │   ├── Dockerfile            # FROM debian:12 + installs nginx
│       │   ├── entrypoint.sh         # Generates a self-signed TLS certificate and starts nginx
│       │   └── conf/nginx.conf       # TLSv1.3, server blocks for ports 443/80, fastcgi_pass to wordpress:9000
│       └── wordpress/
│           ├── Dockerfile            # FROM debian:12 + php-fpm + wp-cli
│           └── entrypoint.sh         # Generates wp-config.php, installs WordPress, creates users and starts php-fpm
├── Makefile
├── Readme.md
├── USER_DOC.md
└── DEV_DOC.md
```

Each Dockerfile builds **its own image from Debian 12** (prebuilt nginx, WordPress or MariaDB
images are never pulled from Docker Hub, as prohibited by the project subject).

---

## 5. Useful Commands for Managing Containers and Volumes

```bash
# Service status
docker compose -f srcs/docker-compose.yml ps

# Live logs (all services)
docker compose -f srcs/docker-compose.yml logs -f

# Logs from a specific service
docker logs -f mariadb_container

# Open a shell inside a running container (debugging)
docker exec -it wordpress_container sh
docker exec -it mariadb_container sh

# Rebuild only one service
docker compose -f srcs/docker-compose.yml up -d --build mariadb

# List named volumes and inspect their actual mount points
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_files
```

---

## 6. Where and How Data Is Persisted

The project uses **Docker named volumes** (instead of direct bind mounts in the service
`volumes:` section), configured with `driver_opts` so that their physical contents are stored
in a fixed host directory, as required by the project subject:

```yaml
volumes:
  wordpress_files:
    driver: local
    driver_opts:
      type: none
      device: /home/fmesa-or/data/wordpress_files
      o: bind
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      device: /home/fmesa-or/data/mariadb_data
      o: bind
```

| Volume | Contents | Physical Host Path | Mounted In |
|---|---|---|---|
| `wordpress_files` | Entire WordPress directory (core, themes, plugins, uploads) | `/home/fmesa-or/data/wordpress_files` | `wordpress_container:/var/www/html` and also `nginx_container:/var/www/html` (NGINX must be able to serve static files and locate `index.php`) |
| `mariadb_data` | MariaDB data files (`datadir`) | `/home/fmesa-or/data/mariadb_data` | `mariadb_container:/var/lib/mysql` |

**Persistence:** running `make down` does not affect the volumes—the data remains on the host
and is available again when the containers are started. Data is only removed by
`make downv` (removes the volumes) or `make fclean` (also deletes the physical host directory).

**Why this approach instead of a direct bind mount?** The project subject explicitly requires
**named volumes** for these two use cases (raw bind mounts are not allowed). Using
`driver: local` together with `driver_opts type=none,o=bind` provides the best of both worlds:
Docker manages them as named volumes (they appear in `docker volume ls`, can be inspected,
and can be removed with `-v`), while their physical contents are stored in the exact host
location required by the subject (`/home/login/data`).