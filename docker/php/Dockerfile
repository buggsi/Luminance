# syntax=docker/dockerfile:latest
FROM php:8.2-fpm

RUN <<EOF
apt-get update
apt-get install -y curl git iputils-ping procps

# https://github.com/mlocati/docker-php-extension-installer
curl -sSLf -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions
chmod +x /usr/local/bin/install-php-extensions

install-php-extensions curl date igbinary mbstring memcached mysqlnd pdo_mysql xml zip

# Install the latest version of Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --filename=composer --install-dir=/usr/local/bin
php -r "unlink('composer-setup.php');"
EOF

# FIX for php-fpm access permission on local folder using the current user
# https://stackoverflow.com/a/70022208/3663357 also works
# Every user using this image can pass himself into it while building: docker-compose build --build-arg UID=$(id -u) --build-arg GID=$(id -g)
# more flexible solution, but same as: RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
ARG uname=www-data
ARG ugroup=www-data
ARG uid=$uid
ARG gid=$gid
RUN echo $uid $uname $gid $ugroup && \
    usermod --uid $uid $uname && groupmod --gid $gid $ugroup
