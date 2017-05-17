FROM php:7.1-apache
ADD ./apache-config.conf /etc/apache2/sites-available/000-default.conf
RUN docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql
RUN a2enmod rewrite
RUN service apache2 restart
