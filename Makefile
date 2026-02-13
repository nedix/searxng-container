setup:
	@test -e .env || cp .env.example .env
	@docker build --progress plain -f Containerfile -t searxng .

destroy:
	-@docker rm -fv searxng

up: HTTP_PORT = "80"
up:
	@docker run \
		--env-file .env \
		--name searxng \
		--rm \
		-p 127.0.0.1:$(HTTP_PORT):80 \
		-d \
		searxng
	@docker logs -f searxng

down:
	-@docker stop searxng

shell:
	@docker exec -it searxng /bin/sh

test:
	@$(CURDIR)/tests/index.sh
