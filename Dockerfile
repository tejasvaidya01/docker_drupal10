# Use a specific version of Drupal with PHP 8.1
#FROM drupal:10.1-apache

# Use an official PHP image as a base
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    python3-software-properties \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    gnupg2 \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:ondrej/php

# Install PHP 8 dependencies and Apache modules (mod_rewrite, etc.)
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php8.1-cli \
    php8.1-mysql \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-curl \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite (for Drupal's clean URLs)
RUN a2enmod rewrite

# Download and Install a specific version of Drupal (e.g., Drupal 10.1.1)
RUN cd ~/ && curl -fsSL https://ftp.drupal.org/files/projects/drupal-10.1.1.tar.gz -o drupal-10.1.1.tar.gz \
    && tar -xvzf drupal-10.1.1.tar.gz -C /var/www/html --strip-components=1 \
    && rm drupal-10.1.1.tar.gz

# Set proper permissions for Drupal files
#RUN chown -R www-data:www-data /var/www/html

# Custom Apache configuration file
COPY ./apache/vhost.conf /etc/apache2/sites-available/000-default.conf
#COPY ./apache/default.conf /etc/apache2/apache2.conf

# Copy PHP custom configuration
#COPY ./config/php.ini /etc/php/8.1/apache2/php.ini
# Copy the PHP override file instead of the entire php.ini
COPY ./config/php.ini /etc/php/8.1/apache2/conf.d/99-custom.ini

# Expose the necessary port
EXPOSE 80

# Set the working directory and set permissions for Drupal files
WORKDIR /var/www/html
#RUN chown -R www-data:www-data /var/www/html

# Start Apache in the foreground
#CMD ["apache2-foreground"]

# Set the default command to run Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
