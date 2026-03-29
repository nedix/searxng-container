#!/usr/bin/env sh

: ${CATEGORIES:="general,images,videos"}
: ${DEFAULT_ENGINES:="bitchute,duckduckgo,duckduckgo images,duckduckgo videos,mojeek,mojeek images,odysee,presearch,startpage,startpage images,yahoo"}
: ${IS_PUBLIC_INSTANCE:="true"}
: ${SECRET_KEY}

# -------------------------------------------------------------------------------
#    Bootstrap searxng services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create searxng-configure environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/searxng-configure/environment

    echo "$CATEGORIES"         > /run/searxng-configure/environment/CATEGORIES
    echo "$DEFAULT_ENGINES"    > /run/searxng-configure/environment/DEFAULT_ENGINES
    echo "$IS_PUBLIC_INSTANCE" > /run/searxng-configure/environment/IS_PUBLIC_INSTANCE
    echo "$SECRET_KEY"         > /run/searxng-configure/environment/SECRET_KEY
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
