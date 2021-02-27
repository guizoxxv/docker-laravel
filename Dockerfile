FROM php:8-apache

ENV APACHE_DOCUMENT_ROOT ${APACHE_DOCUMENT_ROOT:-/var/www/html/public}

RUN apt-get update

# Required for zip; php zip extension; png; node; vim; gd; gd; postgres;
RUN apt install -y zip libzip-dev libpng-dev gnupg vim libfreetype6-dev libjpeg62-turbo-dev libpq-dev

# PHP extensions - pdo-pgsql; zip (used to download packages with Composer); exif
RUN docker-php-ext-install pdo_pgsql zip exif

# PHP extension - GD (image library)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Copy custom apache virtual host configuration into container
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Set apache folder permission
RUN chown -R www-data:www-data /var/www

# Activate Apache mod_rewrite
RUN a2enmod rewrite

# Cleanup
RUN apt-get clean
RUN apt-get autoclean
