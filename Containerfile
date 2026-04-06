ARG ALPINE_VERSION=3.23.3
ARG PYTHON_VERSION=3.12
ARG S6_OVERLAY_VERSION=3.2.2.0
ARG SEARXNG_VERSION=bab3879cba1be6cf1e8bea7a032cc457c204f6ad
ARG VALKEY_VERSION=9.0.3
ARG YQ_VERSION=4.52.5

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

FROM base

ARG PYTHON_VERSION
ARG VALKEY_VERSION

RUN apk add \
        "python${PYTHON_VERSION%.*}~${PYTHON_VERSION}" \
        "valkey-cli~${VALKEY_VERSION}" \
        "valkey~${VALKEY_VERSION}"

COPY --link --from=searxng "/root/.local/lib/python${PYTHON_VERSION}/site-packages/" "/usr/lib/python${PYTHON_VERSION}/site-packages/"
COPY --link --from=searxng /build/searxng/ /usr/local/searxng/
COPY --link --from=searxng /root/.local/bin/granian /usr/bin/
COPY --link --from=yq /build/yq/yq /usr/bin/

COPY --link /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# SearxNG
EXPOSE 80/tcp

VOLUME /var/lib/valkey/
