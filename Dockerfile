FROM php:8-apache

RUN a2enmod rewrite

RUN apt-get update && \
    apt-get install -y \
    libzip-dev \
    unzip \
    default-mysql-client

COPY . /var/www/html

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

RUN chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
