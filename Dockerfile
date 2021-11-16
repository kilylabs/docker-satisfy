FROM alpine:3

ARG APP_USER=satisfy

ENV \
    COMPOSER_VERSION=2.1.12 \
    SATISFY_VERSION=3.3.0 \
    LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
    PHP_INI_PATH=/etc/php7/php.ini \
    PHP_INI_SCAN_DIR=/etc/php7/conf.d \
    APP_ROOT=/app \
    APP_USER=${APP_USER}

LABEL \
      maintainer="Anastas Dancha <https://github.com/anapsix>" \
      com.php.composer.version="${COMPOSER_VERSION}" \
      playbloom.satisfy.version="${SATISFY_VERSION}"

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache php7-apcu php7-bcmath php7-ctype php7-curl php7-dom php7-fileinfo \
      php7-iconv php7-json php7-mbstring php7-openssl php7-phar php7-session \
      php7-simplexml php7-xml php7-xmlwriter php7-tokenizer \
      nginx unit-php7 lockfile-progs \
      libxml2-dev inotify-tools jq zip curl openssh-client git && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gosu && \
    curl -o /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    chmod +x /usr/local/bin/composer && \
    rm -rf /var/cache/apk/* && \
    if [[ "$APP_USER" != "root" ]]; then adduser -h ${APP_ROOT} -D -H ${APP_USER}; fi

WORKDIR ${APP_ROOT}

RUN \
    yes | composer create-project --no-dev -n playbloom/satisfy . ${SATISFY_VERSION} && \
    yes | composer require -n symfony/dotenv && \
    if [ -e ${APP_ROOT}/config/parameters.yml ]; then rm ${APP_ROOT}/config/parameters.yml; fi && \
    if [ ! -e ${APP_ROOT}/data ]; then mkdir ${APP_ROOT}/data; fi && \
    echo "HTTP server is up" > ${APP_ROOT}/web/serverup.txt && \
    chown -R ${APP_USER}:${APP_USER} ${APP_ROOT}

COPY script/*.sh /
COPY config/bootstrap.php ${APP_ROOT}/config/bootstrap.php
COPY config/env ${APP_ROOT}/.env
COPY config/unit.json /var/lib/unit/conf.json
COPY config/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "satisfy" ]
