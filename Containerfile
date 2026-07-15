ARG ALPINE_VERSION=3.24.1
ARG PYTHON_VERSION=3.14
ARG S6_OVERLAY_VERSION=3.2.2.0
ARG SEARXNG_VERSION=7b2199ecdf75a00981583fa2f392a785dfc4fcee
ARG TRAEFIK_VERSION=3.7.8
ARG VALKEY_VERSION=9.1.0
ARG YQ_VERSION=4.53.3

FROM ghcr.io/nedix/alpine-base-container:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add \
        git \
    && apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64) \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

ENV PATH="~/.local/bin:${PATH}"

FROM base AS build-base

ARG PYTHON_VERSION

RUN apk add \
        "py${PYTHON_VERSION%.*}-pip" \
        "python${PYTHON_VERSION%.*}-dev~${PYTHON_VERSION}"

FROM build-base AS searxng

WORKDIR /build/searxng/

ARG SEARXNG_VERSION

RUN git clone --depth 1 --recursive https://github.com/searxng/searxng.git . \
    && git checkout "$SEARXNG_VERSION" \
    && pip install \
        --break-system-packages \
        --user \
        -r requirements-server.txt \
        -r requirements.txt

FROM build-base AS traefik

WORKDIR /build/traefik/

ARG TRAEFIK_VERSION

RUN case "$(uname -m)" in \
        aarch64|arm*) \
            TRAEFIK_ARCHITECTURE="arm64" \
        ;; x86_64) \
            TRAEFIK_ARCHITECTURE="amd64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_${TRAEFIK_ARCHITECTURE}.tar.gz" \
    | tar xzOf - traefik > traefik \
    && chmod +x traefik

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
    && wget -qO- "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${YQ_ARCHITECTURE}.tar.gz" \
    | tar xzOf - "./yq_linux_${YQ_ARCHITECTURE}" > yq \
    && chmod +x yq

FROM valkey/valkey:${VALKEY_VERSION}-alpine AS valkey

FROM base

ARG PYTHON_VERSION

RUN apk add \
        "python${PYTHON_VERSION%.*}~${PYTHON_VERSION}"

COPY --link --from=searxng "/root/.local/lib/python${PYTHON_VERSION}/site-packages/" "/usr/lib/python${PYTHON_VERSION}/site-packages/"
COPY --link --from=searxng /build/searxng/ /usr/local/searxng/
COPY --link --from=searxng /root/.local/bin/granian /usr/bin/
COPY --link --from=traefik /build/traefik/traefik /usr/bin/
COPY --link --from=valkey /usr/local/bin/valkey-server /usr/bin/
COPY --link --from=yq /build/yq/yq /usr/bin/

COPY --link /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# Traefik
EXPOSE 80/tcp

VOLUME /var/lib/valkey/

HEALTHCHECK \
    --start-period=15s \
    CMD nc -z 127.0.0.1 80
