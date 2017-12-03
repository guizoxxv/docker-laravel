FROM php:7.2.0-apache-stretch

RUN apt-get update

# PHP extensions

# Zip (used to download packages with Composer)
RUN apt-get install -y zlib1g-dev
RUN docker-php-ext-install zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nodejs (comes with npm)
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN apt-get update && apt-get install -y nodejs

# Install Vim
RUN apt-get install -y vim

# Change Apache root path
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Activate Apache mod_rewrite
RUN a2enmod rewrite
# Replace apache2.conf with custom
COPY apache2.conf /etc/apache2/apache2.conf

# Cleanup
RUN apt-get clean
RUN apt-get autoclean
