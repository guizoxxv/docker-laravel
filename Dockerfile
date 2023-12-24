FROM php:8.3-apache

ENV APACHE_DOCUMENT_ROOT ${APACHE_DOCUMENT_ROOT:-/var/www/html/public}

RUN apt-get update

# Required for zip; php zip extension; node; vim; php mbstring extension; cron;
RUN apt-get install -y zip libzip-dev gnupg vim libonig-dev cron

# PHP extensions - pdo-mysql; zip (used to download packages with Composer); exif
RUN docker-php-ext-install pdo_mysql zip mbstring exif

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh
RUN chmod 500 nsolid_setup_deb.sh
RUN ./nsolid_setup_deb.sh 20
RUN apt-get install nodejs -y

# Copy custom apache virtual host configuration into container
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Copy start stript into container
COPY start.sh /usr/local/bin/start

# Set apache folder permission
RUN chown -R www-data:www-data /var/www

# Activate Apache mod_rewrite
RUN a2enmod rewrite

# Set up the scheduler for Laravel
RUN echo '* * * * * cd /var/www/html && /usr/local/bin/php artisan schedule:run >> /dev/null 2>&1' | crontab -

# Set start script permission
RUN chmod u+x /usr/local/bin/start

# Cleanup
RUN apt-get clean
RUN apt-get autoclean

CMD ["/usr/local/bin/start"]