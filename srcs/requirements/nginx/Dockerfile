FROM debian:12

COPY entrypoint.sh /entrypoint.sh

# Executed while building
RUN chmod +x /entrypoint.sh && \
	apt-get update && \
	apt-get install -y --no-install-recommends nginx openssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


COPY conf/nginx.conf /etc/nginx/nginx.conf

# Executing at start of run container
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 443