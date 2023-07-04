# Menggunakan base image resmi PHP dengan versi 8.2
FROM php:8.2-apache

# Menambahkan dependensi yang dibutuhkan oleh Laravel
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev

# Mengaktifkan mod_rewrite Apache
RUN a2enmod rewrite

# Menginstal ekstensi PHP yang dibutuhkan oleh Laravel
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath opcache zip

# Mengatur direktori kerja
WORKDIR /var/www/html

# Menyalin file-filenya ke direktori kerja
COPY . /var/www/html

# Memberikan akses kepada user www-data
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/storage

# Menyalin konfigurasi Apache
COPY ./docker/apache2.conf /etc/apache2/apache2.conf

# Mengeset timezone PHP
RUN echo "date.timezone = Asia/Jakarta" >> /usr/local/etc/php/php.ini

# Menjalankan perintah composer install untuk menginstal dependensi Laravel
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --optimize-autoloader --no-dev

# Menyalin file .env
COPY .env.example .env

# Membuat key aplikasi Laravel
RUN php artisan key:generate

# Mengeksekusi migrasi database
RUN php artisan migrate --force

# Menjalankan perintah Apache
CMD ["apache2-foreground"]
