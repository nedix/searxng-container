#!/usr/bin/env sh

: ${IS_PUBLIC_INSTANCE:="false"}
: ${SECRET_KEY}

yq -i ".server.secret_key = ${SECRET_KEY}" /etc/searxng/settings.yml

unset SECRET_KEY

yq -i ".engines[].disabled = true" /usr/local/searxng/searx/settings.yml
yq -i ".server.public_instance = ${IS_PUBLIC_INSTANCE}" /etc/searxng/settings.yml

cd /usr/local/searxng/

exec /usr/local/bin/granian \
    --host="0.0.0.0" \
    --interface="wsgi" \
    --no-log \
    --port="80" \
    searx.webapp:app
