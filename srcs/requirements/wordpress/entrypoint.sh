#!/bin/sh
set -e

# Configure PHP-FPM to LISTEN all interfaces
sed -i 's/listen = .*/listen = 0.0.0.0:9000/' /etc/php/8.2/fpm/pool.d/www.conf

# Create wp-config.php if it doesn't exist before
if [ ! -f /var/www/html/wp-config.php ]; then
    cat > /var/www/html/wp-config.php <<- EOF
<?php
define( 'DB_NAME', '${MYSQL_DATABASE}' );
define( 'DB_USER', '${SQL_USER}' );
define( 'DB_PASSWORD', '${SQL_PASS}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';

EOF
    chown www-data:www-data /var/www/html/wp-config.php
fi

# Wait for MariaDB to be reachable before running WP CLI commands.
for i in $(seq 30); do
    if wp db check --path=/var/www/html --allow-root >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# If WP is not installed yet, install it with specific parameters
if ! wp core is-installed --path=/var/www/html --allow-root; then
	wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception 42 - fmesa-or" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="fmesa-or@student.42malaga.com" \
        --skip-email \
        --path=/var/www/html \
        --allow-root

	# Create second user
    wp user create "${WP_SECOND_USER}" "user@student.42malaga.com" --role=author --user_pass="${WP_SECOND_PASS}" --path=/var/www/html --allow-root
fi

# Execute with -F is like daemon off; in nginx
exec php-fpm8.2 -F