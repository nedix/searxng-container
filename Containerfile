ARG ALPINE_VERSION=3.21
ARG PYTHON_VERSION=3.12
ARG SEARXNG_VERSION=d37dc307831ef0f16a6cb2fbb0c5afe9bb5e4258

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
