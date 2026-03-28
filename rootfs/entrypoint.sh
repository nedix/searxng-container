#!/usr/bin/env sh

: ${CATEGORIES:="general,images,videos"}
: ${DEFAULT_ENGINES:="bitchute,duckduckgo,duckduckgo images,duckduckgo videos,mojeek,mojeek images,odysee,presearch,startpage,startpage images,yahoo"}
: ${IS_PUBLIC_INSTANCE:="true"}
: ${SECRET_KEY}

export CATEGORIES
export DEFAULT_ENGINES
export IS_PUBLIC_INSTANCE
export SECRET_KEY

yq -i ".server.secret_key = env(SECRET_KEY)" /etc/searxng/settings.yml

unset SECRET_KEY

yq -i ".engines[].disabled = true" /usr/local/searxng/searx/settings.yml
yq -i ".server.public_instance = env(IS_PUBLIC_INSTANCE)" /etc/searxng/settings.yml

yq -i '.categories_as_tabs = {}
    | (
        strenv(CATEGORIES)
        | split(",")
        | map(trim)
    ) as $x
    | .categories_as_tabs[$x[]] = ~
' /etc/searxng/settings.yml

yq -i '.engines += (
    strenv(DEFAULT_ENGINES)
    | split(",")
    | map(trim)
    | map({
        "name": .,
        "disabled": false
    })
)' /etc/searxng/settings.yml

cd /usr/local/searxng/

exec /usr/local/bin/granian \
    --host="0.0.0.0" \
    --interface="wsgi" \
    --no-log \
    --port="80" \
    searx.webapp:app
