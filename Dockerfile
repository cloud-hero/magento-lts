FROM php:7.4-fpm-alpine

RUN apk add freetype-dev libjpeg-turbo-dev libpng-dev libjpeg gettext libxml2-dev --no-cache && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install soap && \
    docker-php-ext-configure gd \
        --with-freetype=/usr/lib/ \
        --with-jpeg=/usr/lib/ && \
    NUMPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NUMPROC} gd && \
    apk add --no-cache  $PHPIZE_DEPS && pecl install -f xdebug && apk del --no-cache $PHPIZE_DEPS

COPY . /codebase

RUN rm -rf /codebase/.git
RUN addgroup -g 101 nginx
RUN adduser -D -u 101 -G nginx nginx

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
	mv composer.phar /usr/local/bin/composer

RUN cd /codebase && composer install

CMD ["php-fpm", "-F"]%