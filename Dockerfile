FROM php:8.0-apache

# Install packages
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Apache configuration
ENV APACHE_DOCUMENT_ROOT=/lrs/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# Common PHP Extensions
RUN docker-php-ext-install \
    bcmath \
    pdo_pgsql

# Ensure PHP logs are captured by the container
ENV LOG_CHANNEL=stderr

# Copy code and run composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY . /lrs

WORKDIR /lrs

RUN composer install --optimize-autoloader --no-dev \
  && chown -R www-data:www-data .

RUN chmod +x /lrs/docker-entrypoint.sh
ENTRYPOINT [ "/lrs/docker-entrypoint.sh" ]

CMD ["apache2-foreground"]
