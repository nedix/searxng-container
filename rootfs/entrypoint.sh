#!/usr/bin/env sh

: ${AUTOCOMPLETE:="qwant"}
: ${CATEGORIES_AS_TABS:="general,images,videos"}
: ${DEBUG:="false"}
: ${DEFAULT_LANGUAGE:="en-US"}
: ${DEFAULT_LOCALE:="en"}
: ${DEFAULT_THEME:="simple"}
: ${ENABLE_METRICS:="true"}
: ${ENGINES:="bitchute,duckduckgo,duckduckgo images,duckduckgo videos,mojeek,mojeek images,odysee,presearch,startpage,startpage images,youtube"}
: ${FORMATS:="html"}
: ${IMAGE_PROXY:="true"}
: ${PLUGINS:="oa_doi_rewrite,tracker_url_remover"}
: ${PREFERENCES_LOCK:="language"}
: ${PUBLIC_INSTANCE:="true"}
: ${QUERY_IN_TITLE:="true"}
: ${SAFE_SEARCH:="2"}
: ${SEARCH_ON_CATEGORY_SELECT:="true"}
: ${SECRET_KEY}
: ${URL_FORMATTING:="full"}
: ${VALKEY_URL:="unix:///run/valkey/valkey.sock?db=0"}

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
    echo "$CATEGORIES_AS_TABS"        > /run/searxng-configure/environment/CATEGORIES_AS_TABS
    echo "$DEBUG"                     > /run/searxng-configure/environment/DEBUG
    echo "$DEFAULT_LANGUAGE"          > /run/searxng-configure/environment/DEFAULT_LANGUAGE
    echo "$DEFAULT_LOCALE"            > /run/searxng-configure/environment/DEFAULT_LOCALE
    echo "$DEFAULT_THEME"             > /run/searxng-configure/environment/DEFAULT_THEME
    echo "$ENABLE_METRICS"            > /run/searxng-configure/environment/ENABLE_METRICS
    echo "$ENGINES"                   > /run/searxng-configure/environment/ENGINES
    echo "$FORMATS"                   > /run/searxng-configure/environment/FORMATS
    echo "$IMAGE_PROXY"               > /run/searxng-configure/environment/IMAGE_PROXY
    echo "$PLUGINS"                   > /run/searxng-configure/environment/PLUGINS
    echo "$PREFERENCES_LOCK"          > /run/searxng-configure/environment/PREFERENCES_LOCK
    echo "$PUBLIC_INSTANCE"           > /run/searxng-configure/environment/PUBLIC_INSTANCE
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
