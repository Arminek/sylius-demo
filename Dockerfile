ARG PHP_BASE_IMAGE_TAG=8.0-fpm-0.6.0
ARG NODE_BASE_IMAGE_TAG=12-slim-0.6.0
ARG PHP_BASE_IMAGE=ghcr.io/sylius/docker-images-php:${PHP_BASE_IMAGE_TAG}
ARG NODE_BASE_IMAGE=ghcr.io/sylius/docker-images-node:${NODE_BASE_IMAGE_TAG}

FROM ${PHP_BASE_IMAGE} AS php-install
WORKDIR /app
COPY ./composer.json /app/
COPY ./composer.lock /app/
RUN composer install --prefer-dist --no-scripts --no-progress --no-suggest --no-dev --optimize-autoloader;
COPY ./ /app/

FROM ${NODE_BASE_IMAGE} AS node-build
WORKDIR /app
COPY --from=php-install /app /app
RUN yarn install
RUN yarn build

FROM ${PHP_BASE_IMAGE} AS php-runtime
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=sylius
ENV MYSQL_HOST=mysql
ENV MYSQL_PORT=3306
ENV MYSQL_DATABASE_NAME=sylius_%kernel.environment%
ENV APP_ENV=prod
ENV APP_DEBUG=0
WORKDIR /app
COPY ./docker/php/php.ini-production $PHP_INI_DIR/php.ini
COPY --from=node-build /app /app
RUN bin/console assets:install --ansi
RUN bin/console sylius:theme:assets:install
RUN mkdir -p /app/public/media/image
RUN mkdir -p templates/bundles/SyliusAdminBundle/Product/Tab
RUN mkdir -p public/media/vendor-logo
RUN chown -R www-data:www-data /app/var
RUN chown -R www-data:www-data /app/public
USER www-data
