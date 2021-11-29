init: init-containers init-frontend init-backend

init-containers:
	docker-compose up -d

init-frontend: yarn-install yarn-build
init-backend: composer-install composer-dump-env install-assets cache-warmup db-schema-up load-prod-sql-dump

php-shell:
	docker-compose exec php bash

nginx-shell:
	docker-compose exec nginx sh

mysql-shell:
	docker-compose exec mysql bash -c "\
		mysql -uroot -psylius \
	"

up: init

up-only-backend: init-containers init-backend

up-no-init:
	docker-compose up -d

composer-install:
	docker-compose exec php bash -c "\
		composer install --prefer-dist --no-scripts --no-autoloader \
	"

composer-dump-env:
	docker-compose exec php bash -c "\
		composer dump-env dev \
	"

yarn-install:
	docker run -v="$(PWD):/app" -w="/app" --rm ghcr.io/sylius/docker-images-node:12-slim-0.6.0 bash -c "\
		yarn install \
	"

yarn-build:
	docker run -v="$(PWD):/app" -w="/app" --rm ghcr.io/sylius/docker-images-node:12-slim-0.6.0 bash -c "\
		yarn build \
	"

db-migration: db-create
	docker-compose exec php bash -c "\
		bin/console doctrine:migrations:migrate -n --allow-no-migration; \
		bin/console doctrine:schema:validate; \
	"

db-schema-up: db-create
	docker-compose exec php bash -c "\
		bin/console doctrine:schema:up --force; \
		bin/console doctrine:schema:validate; \
	"

db-create:
	docker-compose exec php bash -c "\
		bin/console doctrine:database:create  --if-not-exists; \
	"

sylius-install:
	docker-compose exec php bash -c "\
		bin/console sylius:install -n; \
	"

prod-up: prod-image-build init-prod-containers wait-for-db db-create load-prod-sql-dump
prod-up-without-rebuild-image: init-prod-containers wait-for-db db-create load-prod-sql-dump

init-prod-containers:
	docker-compose -f docker-compose-prod.yml up -d

prod-image-build:
	docker-compose -f docker-compose-prod.yml build

wait-for-db: #the time required to start db depends on your host machine
	sleep 60

load-prod-sql-dump:
	docker-compose exec mysql bash -c "\
		cat fixtures.sql | mysql -uroot -psylius sylius_prod; \
	"

sylius-fixtures-load:
	docker-compose exec php bash -c "\
		bin/console sylius:fixture:load -n; \
	"

cache-warmup:
	docker-compose exec php bash -c "\
		bin/console cache:clear -n; \
		bin/console cache:warmup -n; \
	"

install-assets:
	docker-compose exec php bash -c "\
		bin/console assets:install -n --ansi; \
	"

down:
	docker-compose down --remove-orphans
