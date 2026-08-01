COLOR = \033[38;5;208m
RESET = \033[0m


# Start all services and force rebuild containers
build:
	@mkdir -p /home/fmesa-or/data/wordpress_files 2>/dev/null
	@mkdir -p /home/fmesa-or/data/mariadb_data 2>/dev/null
	@docker compose -f ./srcs/docker-compose.yml up --build


# Start all services in docker-compose
up:
	@mkdir -p /home/fmesa-or/data/wordpress_files 2>/dev/null
	@mkdir -p /home/fmesa-or/data/mariadb_data 2>/dev/null
	@docker compose -f ./srcs/docker-compose.yml up


# Stop and remove all containers defined in docker-compose
down:
	@docker compose -f ./srcs/docker-compose.yml down


# Same as "down" but also removes volumes (data persistence)
downv:
	@docker compose -f ./srcs/docker-compose.yml down -v


# Start an existent container
start:
	@docker compose -f ./srcs/docker-compose.yml start


# Stop current container running
stop:
	@docker compose -f ./srcs/docker-compose.yml stop


# Remove all containers, images and volumes
rm-all:
	@docker stop $$(docker ps -aq) 2>/dev/null || true
	@docker rm $$(docker ps -aq) 2>/dev/null || true
	@docker rmi $$(docker images -q) 2>/dev/null || true
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker builder prune -a -f 2>/dev/null || true

# rm-all + remove all local volumes
fclean: rm-all
	@sudo rm -rf /home/fmesa-or/data


# Show all containers and images
show:
	@docker ps -a
	@docker images -a
	@docker volume ls


db:
	@mkdir -p /home/fmesa-or/data/mariadb_data 2>/dev/null || true
	@docker compose -f ./srcs/docker-compose.yml up -d mariadb
# 	@docker build -t mariadb_img -f ./srcs/requirements/mariadb/Dockerfile ./srcs/requirements/mariadb
# 	@docker rm -f mariadb_container 2>/dev/null || true
# 	@docker run --name mariadb_container mariadb_img


# Show all commands
help:
	@echo "$(COLOR)- up$(RESET): Start all services in docker-compose"
	@echo "$(COLOR)- build$(RESET): Start all services and force rebuild containers"
	@echo "$(COLOR)- down$(RESET): Stop and remove all containers defined in docker-compose"
	@echo "$(COLOR)- downv$(RESET): Same as 'down' but also removes volumes (data persistence)"
	@echo "$(COLOR)- start$(RESET): Start an existent container"
	@echo "$(COLOR)- stop$(RESET): Stop current container running"
	@echo "$(COLOR)- rm-all$(RESET): Remove all containers and images"
	@echo "$(COLOR)- fclean$(RESET): rm-all + remove local data"
	@echo "$(COLOR)- show$(RESET): Show all containers and images"
	@echo "$(COLOR)- db$(RESET): Build and run mariadb container"
	@echo "$(COLOR)- help$(RESET): Show this help message"