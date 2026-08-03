*This project has been created as part of the 42 curriculum by fmesa-or.*

# INCEPTION
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=flat-square&logo=docker&logoColor=white) ![Docker Compose](https://img.shields.io/badge/Docker%20Compose-Orchestration-1E3A8A?style=flat-square&logo=docker&logoColor=white) ![NGINX](https://img.shields.io/badge/NGINX-Reverse%20Proxy-009639?style=flat-square&logo=nginx&logoColor=white) ![WordPress](https://img.shields.io/badge/WordPress-CMS-21759B?style=flat-square&logo=wordpress&logoColor=white) ![MariaDB](https://img.shields.io/badge/MariaDB-Database-003545?style=flat-square&logo=mariadb&logoColor=white) ![Debian](https://img.shields.io/badge/Debian-12-A81D33?style=flat-square&logo=debian&logoColor=white) ![TLS](https://img.shields.io/badge/TLS-HTTPS-blue?style=flat-square) ![Linux](https://img.shields.io/badge/Linux-Host-FCC624?style=flat-square&logo=linux&logoColor=black) ![42 School](https://img.shields.io/badge/42-School-000000?style=flat-square)

</div>

---

## Description

Inception is a system administration project focused on containerized infrastructure using Docker.
The goal is to build a small but complete web stack from scratch, where each service runs in its own container and all services communicate through an isolated Docker network.

This repository deploys a WordPress website over HTTPS with NGINX as reverse proxy/web server, PHP-FPM for dynamic PHP execution, and MariaDB as the database backend.

The project is based on:

- Custom Docker images built from Debian 12 for each required service.
- Multi-service orchestration with Docker Compose.
- Persistent data for WordPress files and MariaDB data through mounted host paths.
- Runtime configuration through an environment file consumed by all services.

## Instructions

### Requirements

- Docker Engine installed and running.
- Docker Compose plugin available.
- Linux host path support for persistent volumes.
- Domain mapped locally to your machine (for this project: fmesa-or.42.fr).

#### Steps
```bash

# Acces to root superuser
su

# Update packages
apt update
apt upgrade

#Access to https://docs.docker.com/engine/install/debian/ and follow instructions

# Install certifications
sudo apt install ca-certificates curl

# Create the keyring for the GPG key that APT uses to verify the repos are not being manipulated
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the docker repository to the APT sources and update APT
echo \
"deb [arch=$ (dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list /dev/null
apt-get update

# Now we can install docker
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify that docker is runing
sudo systemctl status docker

# If not you can use
sudo systemctl start docker

# Try run this image
sudo docker run hello-world

# Add user to docker group so there's no need to use sudo all the time
su -
usermod -aG docker <username>

# Reest your VM as last step
 ```

### Installation

1. Clone the repository.
2. Move into the project root.
3. Edit srcs/.env with your own credentials and domain if needed.
4. Add your domain to hosts file (example: 127.0.0.1 fmesa-or.42.fr).

### Build and Run

Use Makefile targets from the project root:

```bash
make build   # Start all services and force rebuild containers
```

Main available targets:

```text
- make up: start services without forcing rebuild.
- make down: stop and remove containers.
- make downv: stop/remove containers and attached volumes.
- make start: start already created containers.
- make stop: stop running containers.
- make show: show containers, images and volumes.
- make fclean: full cleanup including host data directory.
```

### Access

- HTTPS site: https://fmesa-or.42.fr
- HTTP requests on port 80 are redirected to HTTPS.

### Useful Checks

Use these commands to quickly verify runtime status and troubleshoot startup issues:

```bash
docker compose -f srcs/docker-compose.yml ps		# Shows service state, container names, and exposed ports.
docker compose -f srcs/docker-compose.yml logs -f	# Streams live logs from all services to detect errors in real time.
```

## Project Structure

```text
inception/
├── docs/
│   └── en.subject.pdf
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── entrypoint.sh
│       │   └── conf/50-server.cnf
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── entrypoint.sh
│       │   └── conf/nginx.conf
│       └── wordpress/
│           ├── Dockerfile
│           └── entrypoint.sh
├── Makefile
└── Readme.md
```

## Docker Design and Main Choices

- One process responsibility per container:
	- nginx container serves TLS and forwards PHP requests.
	- wordpress container runs PHP-FPM and WordPress setup.
	- mariadb container handles relational data persistence.
- Isolated custom bridge network named inception for inter-service communication.
- Persistent storage through Docker-managed volumes mapped to fixed host directories.
- Runtime bootstrapping in entrypoint scripts:
	- MariaDB initialization and user/database creation.
	- NGINX self-signed certificate generation.
	- WordPress installation and user provisioning via WP-CLI.

## Technical Comparisons

### Virtual Machines vs Docker

- Virtual Machines emulate full operating systems with their own kernel space; they are heavier in
	CPU, RAM and storage usage.
- Docker containers share the host kernel, so startup is faster and resource consumption is lower.
- For this project, Docker is a better fit because it simplifies reproducible multi-service
	environments and makes orchestration with Compose straightforward.

### Secrets vs Environment Variables

- Environment variables are simple and practical for local development and 42 evaluation workflows.
- Docker secrets are safer for production because they avoid exposing sensitive values directly in
	env files and process environments.
- This repository uses env_file (.env) for simplicity and project constraints, but production-grade
	deployments should prefer secrets for credentials.

### Docker Network vs Host Network

- Bridge networks provide service isolation, internal DNS (service-name resolution), and controlled
	port publication.
- Host networking removes isolation and maps container networking directly to the host stack.
- This project uses a bridge network to keep services isolated while exposing only the required
	public endpoint (HTTPS via NGINX).

### Docker Volumes vs Bind Mounts

- Docker volumes are managed by Docker and are usually cleaner for portability and lifecycle
	management.
- Bind mounts map exact host paths and provide direct visibility/control of files from the host.
- In this project, the compose file uses local driver volumes with bind options to map data to
	/home/fmesa-or/data, combining persistence with explicit host-side location control.

## Resources

- [The Only Docker Tutorial You Need To Get Started](https://www.youtube.com/watch?v=DQdB7wFEygo)
- [Inception - 42 Common Core](https://www.youtube.com/watch?v=wGJFx-H6KX8)
- [Docker Crash Course for Absolute Beginners [NEW]](https://www.youtube.com/watch?v=pg19Z8LL06w)
- [42Kocaeli Inception Projesi](https://www.youtube.com/watch?v=BjbhxtUjkhg)
- [Instalar Docker y Docker Compose en un VPS Debian (paso a paso)](https://www.youtube.com/watch?v=-FVOr1M763I)
- [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/reference/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress documentation](https://developer.wordpress.org/)
- [WP-CLI documentation](https://developer.wordpress.org/cli/commands/)

## AI Usage

AI was used as a support tool for documentation and explanation tasks:

- Structuring and polishing this README sections.
- Verifying clarity and completeness of technical comparisons.
- Improving wording and consistency in setup instructions.

AI was not used to replace understanding of Docker concepts, service configuration, or runtime
debugging decisions made during implementation.
