FROM alpine:3.8

ARG BUILD_DATE
ARG VCS_REF
ARG PHP_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://gitlab.dobrev.eu/docker/hello-world-bg-ab.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Dobrev IT LTD." \
      org.label-schema.name="hello-world-bg-ab" \
      org.label-schema.description="Docker image with PHP ${PHP_VERSION}, Apache2 and Alpine" \
      org.label-schema.url="https://gitlab.dobrev.eu/docker/hello-world-bg-ab"

ENV \
    PHP_VERSION=${PHP_VERSION:-'7.2'} \
    DEPS="bash \
        file \
        runit" \
    PHP_DEPS="php${PHP_VERSION}-curl \
        php${PHP_VERSION}-apache2 \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-mcrypt \
        php${PHP_VERSION}-pdo \
        php${PHP_VERSION}-pdo_pgsql \
        php${PHP_VERSION}-gmp \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-opcache\
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-pear \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-tidy"

ADD https://repos.dobrev.it/alpine/dobrevit.rsa.pub /etc/apk/keys/dobrevit.rsa.pub

RUN set -x \
    && echo "http://repos.dobrev.it/alpine/v3.8" >> /etc/apk/repositories \
    && apk add --no-cache $DEPS $PHP_DEPS \
    && sed -i \
        -e "s/\/var\/www\/localhost\/htdocs/\/var\/www\/html/g" \
        -e "s/^ServerTokens.*/ServerTokens Prod/g" \
        -e "s/^ServerSignature.*/ServerSignature Off/g" \
        /etc/apache2/httpd.conf \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    && mkdir -p /run/apache2 \
    && rm -rf /*.xml /var/www/localhost /var/cache/apk/*

EXPOSE 80

COPY ./.docker/hello-world /

CMD ["/sbin/runit-wrapper"]
