FROM php:7.2.3-apache-stretch

RUN apt update

# Required for php zip extension; PNG; required to install node; vim; required for postgres
RUN apt install -y zlib1g-dev libpng-dev gnupg vim libpq-dev

# PHP extensions

# PDO; Zip (used to download packages with Composer)
RUN docker-php-ext-install pdo_mysql pdo_pgsql zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nodejs (comes with npm)
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt update && apt-get install -y nodejs

# Change Apache root path
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Activate Apache mod_rewrite
RUN a2enmod rewrite
# Replace apache2.conf with custom
COPY apache2.conf /etc/apache2/apache2.conf

# Cleanup
RUN apt clean
RUN apt autoclean
