ARG ALPINE_VERSION=3.23
ARG PYTHON_VERSION=3.14
ARG SEARXNG_VERSION=a5c946a321a6b5edeacc789b673b04456e45530b

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
        /var/log/uwsgi/

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
