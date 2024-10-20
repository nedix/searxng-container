setup:
	@docker build --progress plain -f Containerfile -t searxng .

up: PORT = 8080
up:
	@docker run --rm --name searxng \
		--env-file=".env" \
		-p 127.0.0.1:$(PORT):80 \
		-d \
		searxng

down:
	@-docker rm -fv searxng
	@-docker rm -fv searxng-test
