# [⚠️ Not ready for production ⚠️](https://github.com/nedix/searxng-uwsgi-docker/issues/30)

# [searxng-container](https://github.com/nedix/searxng-container)

Metasearch-engine that combines search results from multiple sources.

## Usage

#### 1. Start the server

This example command will start the server on port `8080`.

```shell
docker run --pull always --rm --name searxng \
    -p 8080:80 \
    -d \
    nedix/searxng
```

#### 2. Start searching

- Navigate to SearxNG on http://127.0.0.1:8080
- Type a search query
- Press enter or click the search button

<hr>

## Attribution

Powered by [SearxNG].

[SearxNG]: https://github.com/searxng/searxng
