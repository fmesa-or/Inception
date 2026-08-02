FROM debian:12


COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates php-fpm php-mysql curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

# When use tar with --strip-components=1 we remove the top-level dir,
# so all WordPress files are extracted directly into /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 && \
    rm latest.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html


ENTRYPOINT [ "/entrypoint.sh" ]


EXPOSE 9000


# BEFORE (less layers, more efficiency but less maintanibility and readability):

	# RUN chmod +x /entrypoint.sh && \
	# apt-get update && \
	# apt-get install -y --no-install-recommends ca-certificates php-fpm php-mysql curl && \
	# mkdir -p /var/www/html && \
	# curl -O https://wordpress.org/latest.tar.gz && \
	# tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 && \
	# rm latest.tar.gz && \
	# chown -R www-data:www-data /var/www/html && \
	# chmod -R 755 /var/www/html && \
	# apt-get clean && \
	# rm -rf /var/lib/apt/lists/*