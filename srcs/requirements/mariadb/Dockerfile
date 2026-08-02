FROM debian:12

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
	apt-get update && \
	apt-get install -y --no-install-recommends mariadb-server && \
	mkdir -p /run/mysqld && \
	chown mysql:mysql /run/mysqld && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

	
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 3306