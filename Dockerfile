# Gunakan base image Ubuntu
FROM ubuntu:latest

# Update dan install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    zip \
    unzip \
    nginx \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-curl \
    php8.2-zip \
    supervisor

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Konfigurasi Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Menyalin kode sumber Laravel ke dalam container
COPY . /var/www/html

# Menjalankan perintah-perintah instalasi dan konfigurasi Laravel
WORKDIR /var/www/html
RUN composer install --optimize-autoloader --no-dev
RUN chown -R www-data:www-data /var/www/html/storage
RUN php artisan config:cache
RUN php artisan route:cache

# Expose port 80
EXPOSE 80

# Menjalankan Nginx dan PHP-FPM menggunakan Supervisor
CMD ["/usr/bin/supervisord", "-n"]
