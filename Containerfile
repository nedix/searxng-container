ARG ALPINE_VERSION=3.23
ARG PYTHON_VERSION=3.14
ARG SEARXNG_VERSION=7ac4ff39fee4cdde223dbab6a83af9c26b56366e
ARG YQ_VERSION=4.52.5

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS base

RUN apk add \
        git

FROM base AS build-base

RUN apk add \
        build-base \
        curl

FROM build-base AS searxng

WORKDIR /usr/local/searxng/

ARG SEARXNG_VERSION

RUN git clone https://github.com/searxng/searxng.git . \
    && git checkout "$SEARXNG_VERSION" \
    && pip install --upgrade pip \
    && pip install \
        --no-cache \
        -r requirements.txt \
        -r requirements-server.txt

FROM build-base AS yq

WORKDIR /build/yq/

ARG YQ_VERSION

RUN case "$(uname -m)" in \
        aarch64) \
            YQ_ARCHITECTURE="arm64" \
        ;; arm*) \
            YQ_ARCHITECTURE="arm64" \
        ;; x86_64) \
            YQ_ARCHITECTURE="amd64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${YQ_ARCHITECTURE}.tar.gz" \
    | tar xzOf - "./yq_linux_${YQ_ARCHITECTURE}" > yq \
    && chmod +x yq

FROM base

ARG PYTHON_VERSION

COPY --link --from=searxng "/usr/local/lib/python${PYTHON_VERSION}/site-packages/" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/"
COPY --link --from=searxng /usr/local/bin/granian /usr/local/bin/
COPY --link --from=searxng /usr/local/searxng/ /usr/local/searxng/
COPY --link --from=searxng /usr/local/searxng/searx/limiter.toml /etc/searxng/limiter.toml
COPY --link --from=yq /build/yq/yq /usr/local/bin/

COPY --link /rootfs/ /

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
