#!/usr/bin/env sh

set -e

: ${UWSGI_THREADS:="4"}
: ${UWSGI_WORKERS:="%k"}

PYTHON_PATH="$(python -c 'import site; print(site.getsitepackages()[0])')"

sed -E \
    -e "s|(threads =).*|\1 ${UWSGI_THREADS}|" \
    -e "s|(workers =).*|\1 ${UWSGI_WORKERS}|" \
    -i /usr/local/searxng/dockerfiles/uwsgi.ini

sed -E \
    -e "s|(pythonpath =).*|\1 ${PYTHON_PATH}|" \
    -i /etc/searxng/uwsgi.ini

exec uwsgi --http-socket 0.0.0.0:80 \
    --ini /usr/local/searxng/dockerfiles/uwsgi.ini \
    --ini /etc/searxng/uwsgi.ini
