# Menggunakan base image Ubuntu 20.04
FROM ubuntu:20.04

# Update paket dan instal dependensi yang diperlukan
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    nginx \
    software-properties-common

# Install PHP 8.2
RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php8.2-cli php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set work directory
WORKDIR /var/www/html

# Copy source code ke work directory
COPY . .

# Install dependencies menggunakan Composer
RUN composer install --no-interaction --no-scripts --no-suggest --prefer-dist

# Konfigurasi Nginx
COPY nginx/default /etc/nginx/sites-available/default

# Set permission pada storage dan cache Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 untuk HTTP
EXPOSE 80

# Jalankan Nginx dan PHP-FPM
CMD service nginx start && service php8.2-fpm start
