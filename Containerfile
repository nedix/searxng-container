ARG ALPINE_VERSION=3.21
ARG PYTHON_VERSION=3.12
ARG SEARXNG_VERSION=09cce18518bc13bba6aea5a8223a178c6fd02183

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

ARG SEARXNG_VERSION

RUN apk add --virtual .build-deps \
        build-base \
    && apk add \
        git \
        uwsgi-python3 \
    && git clone https://github.com/searxng/searxng.git /usr/local/searxng \
    && cd /usr/local/searxng \
    && git checkout "$SEARXNG_VERSION" \
    && pip install --upgrade pip \
    && pip install --no-cache -r requirements.txt \
    && apk del .build-deps

COPY --link rootfs /

RUN chown -R nobody \
        /usr/local/searxng \
        /var/log/uwsgi/ \
    && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
