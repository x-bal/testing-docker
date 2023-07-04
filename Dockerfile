# Use the official PHP 8 base image
FROM php:8-apache

# Set the working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip

# Enable mod_rewrite
RUN a2enmod rewrite

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath opcache zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the Laravel application files
COPY . /var/www/html

# Install dependencies with Composer
RUN composer install --optimize-autoloader --no-dev

# Set the Apache document root
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/g' /etc/apache2/sites-available/000-default.conf

# Change ownership of the application files to the Apache user
RUN chown -R www-data:www-data /var/www/html/storage

# Generate Laravel application key
RUN php artisan key:generate

# Expose port 80
EXPOSE 80

# Start the Apache server
CMD ["apache2-foreground"]
