VERSION=latest

init:
	docker-compose run --no-deps web rails new . --force --database=postgresql

command:
	docker-compose run web rails generate controller Articles index --skip-routes

build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose down

db:
	docker-compose run web rake db:create

migrate:
	docker-compose run web rake db:migrate