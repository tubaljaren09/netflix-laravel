# Use PHP 8.2 FPM as a base image
FROM php:8.2-fpm

# Set the working directory
WORKDIR /var/www

# Install system dependencies including SQLite and required PHP extensions
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
    curl \
    sqlite3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel, including PDO extensions for MySQL and SQLite
RUN docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd

# Install Composer from the official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy your Laravel application into the container
COPY . /var/www

# Create the SQLite database file if it doesn't exist
RUN mkdir -p /var/www/database && \
    touch /var/www/database/database.sqlite

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Set proper permissions for Laravel's storage and database directories
RUN chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www/database /var/www/storage

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Laravel's built-in server using the dynamic port from Render
CMD ["sh", "-c", "php artisan serve --host 0.0.0.0 --port ${PORT:-80}"]
