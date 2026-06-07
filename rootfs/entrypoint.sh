#!/usr/bin/env sh

: ${AUTOCOMPLETE:="qwant"}
: ${CATEGORIES:="general,images,videos"}
: ${DEBUG:="false"}
: ${DEFAULT_ENGINES:="bitchute,duckduckgo,duckduckgo images,duckduckgo videos,mojeek,mojeek images,odysee,presearch,startpage,startpage images,youtube"}
: ${DEFAULT_LANGUAGE:="en-US"}
: ${DEFAULT_LOCALE:="en"}
: ${ENABLE_METRICS:="true"}
: ${FORMATS:="html"}
: ${IMAGE_PROXY:="true"}
: ${IS_PUBLIC_INSTANCE:="true"}
: ${PLUGINS:="oa_doi_rewrite,tracker_url_remover"}
: ${PREFERENCES_LOCK:="language"}
: ${QUERY_IN_TITLE:="true"}
: ${SAFE_SEARCH:="2"}
: ${SEARCH_ON_CATEGORY_SELECT:="true"}
: ${SECRET_KEY}
: ${URL_FORMATTING:="full"}

if [ -z "$SECRET_KEY" ]; then
    echo "The SECRET_KEY variable must be defined."
    exit 1
fi

# -------------------------------------------------------------------------------
#    Bootstrap searxng services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create searxng-configure environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/searxng-configure/environment

    echo "$AUTOCOMPLETE"              > /run/searxng-configure/environment/AUTOCOMPLETE
    echo "$CATEGORIES"                > /run/searxng-configure/environment/CATEGORIES
    echo "$DEBUG"                     > /run/searxng-configure/environment/DEBUG
    echo "$DEFAULT_ENGINES"           > /run/searxng-configure/environment/DEFAULT_ENGINES
    echo "$DEFAULT_LANGUAGE"          > /run/searxng-configure/environment/DEFAULT_LANGUAGE
    echo "$DEFAULT_LOCALE"            > /run/searxng-configure/environment/DEFAULT_LOCALE
    echo "$ENABLE_METRICS"            > /run/searxng-configure/environment/ENABLE_METRICS
    echo "$FORMATS"                   > /run/searxng-configure/environment/FORMATS
    echo "$IMAGE_PROXY"               > /run/searxng-configure/environment/IMAGE_PROXY
    echo "$IS_PUBLIC_INSTANCE"        > /run/searxng-configure/environment/IS_PUBLIC_INSTANCE
    echo "$PLUGINS"                   > /run/searxng-configure/environment/PLUGINS
    echo "$PREFERENCES_LOCK"          > /run/searxng-configure/environment/PREFERENCES_LOCK
    echo "$QUERY_IN_TITLE"            > /run/searxng-configure/environment/QUERY_IN_TITLE
    echo "$SAFE_SEARCH"               > /run/searxng-configure/environment/SAFE_SEARCH
    echo "$SEARCH_ON_CATEGORY_SELECT" > /run/searxng-configure/environment/SEARCH_ON_CATEGORY_SELECT
    echo "$SECRET_KEY"                > /run/searxng-configure/environment/SECRET_KEY
    echo "$URL_FORMATTING"            > /run/searxng-configure/environment/URL_FORMATTING
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
