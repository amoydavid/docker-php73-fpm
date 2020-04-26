FROM php:7.3-fpm-alpine

MAINTAINER David <t-liu@qq.com>

ENV TIMEZONE=Asia/Shanghai
RUN sed 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' -i /etc/apk/repositories

#bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zend_test zip

RUN apk add --no-cache gettext libpng sqlite libxml2 libjpeg-turbo freetype libmemcached zlib libzip && \
    apk add --no-cache --virtual .build-dependencies libxml2-dev sqlite-dev zlib-dev libzip-dev \
    gettext-dev curl-dev freetype-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev libpng-dev libmemcached-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-install gettext json gd mysqli bcmath exif curl mbstring opcache pdo pdo_mysql pdo_sqlite soap session xml xmlrpc zip && \
    curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/4.3.0.tar.gz && \
    tar xfz /tmp/redis.tar.gz && \
    rm -r /tmp/redis.tar.gz && \
    mkdir -p /usr/src/php/ext && \
    mv phpredis-4.3.0 /usr/src/php/ext/redis && \
    docker-php-ext-install redis && \
    curl -L -o /tmp/memcached.tar.gz https://github.com/php-memcached-dev/php-memcached/archive/v3.1.3.tar.gz && \
    tar xfz /tmp/memcached.tar.gz && \
    rm -r /tmp/memcached.tar.gz && \
    mkdir -p /usr/src/php/ext && \
    mv php-memcached-3.1.3 /usr/src/php/ext/memcached && \
    docker-php-ext-install memcached && \
    apk add m4 autoconf make gcc g++ linux-headers && pecl install swoole && docker-php-ext-enable swoole && \
    apk del .build-dependencies 



COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

EXPOSE 9000
EXPOSE 5200

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/env", "php-fpm"]
