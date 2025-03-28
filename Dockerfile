# Use PHP 8.2 FPM as a base image
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer from the official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy your Laravel application into the container
COPY . /var/www

# Set correct permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www/storage

# Expose port 80 (HTTP)
EXPOSE 80

# Start Laravel’s built-in development server using the dynamic port from Render
CMD ["sh", "-c", "php artisan serve --host 0.0.0.0 --port ${PORT:-80}"]
