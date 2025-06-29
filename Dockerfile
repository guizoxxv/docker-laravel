FROM php:8.3-apache

ENV APACHE_DOCUMENT_ROOT ${APACHE_DOCUMENT_ROOT:-/var/www/html/public}

RUN apt-get update

# Required for zip; php zip extension; vim; php mbstring extension; cron;
RUN apt-get install -y zip libzip-dev vim libonig-dev cron

# PHP extensions - pdo-mysql; zip (used to download packages with Composer); exif
RUN docker-php-ext-install pdo_mysql zip mbstring exif

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN apt-get install -y gnupg
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs
RUN apt-get remove -y gnupg

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
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

CMD ["/usr/local/bin/start"]
