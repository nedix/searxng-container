#!/usr/bin/env sh

set -e

: ${SECRET_KEY}
: ${UWSGI_THREADS:="4"}
: ${UWSGI_WORKERS:="%k"}

PYTHON_PATH="$(python -c 'import site; print(site.getsitepackages()[0])')"

sed -E \
    -e "s|(threads =).*|\1 ${UWSGI_THREADS}|" \
    -e "s|(workers =).*|\1 ${UWSGI_WORKERS}|" \
    -i /usr/local/searxng/container/uwsgi.ini

sed -E \
    -e "s|(pythonpath =).*|\1 ${PYTHON_PATH}|" \
    -i /etc/searxng/uwsgi.ini

export BIND_ADDRESS="[::]:80"
export SEARXNG_SECRET="$SECRET_KEY"

exec uwsgi \
    --http-socket "$BIND_ADDRESS" \
    --ini /usr/local/searxng/container/uwsgi.ini \
    --ini /etc/searxng/uwsgi.ini
