# [searxng-container][project]

Metasearch-engine to combine search results from multiple sources.

## Usage

### 1. Start the container

This example command will start the container on port `80`.

```shell
docker run --rm --pull always --name searxng \
    -p 127.0.0.1:80:80 \
    -e SECRET_KEY="^&*()_+" \
    nedix/searxng
```

### 2. Start searching

- Navigate to SearxNG on http://127.0.0.1:80
- Type a search query
- Press enter or click the search button


[project]: https://hub.docker.com/r/nedix/searxng
