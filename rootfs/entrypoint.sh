#!/usr/bin/env sh

: ${CATEGORIES}
: ${DEFAULT_ENGINES}
: ${ENABLE_DONATION_URL:="true"}
: ${ENABLE_METRICS:="true"}
: ${IS_PUBLIC_INSTANCE:="true"}
: ${SECRET_KEY}

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

    echo "$CATEGORIES"          > /run/searxng-configure/environment/CATEGORIES
    echo "$DEFAULT_ENGINES"     > /run/searxng-configure/environment/DEFAULT_ENGINES
    echo "$ENABLE_DONATION_URL" > /run/searxng-configure/environment/ENABLE_DONATION_URL
    echo "$ENABLE_METRICS"      > /run/searxng-configure/environment/ENABLE_METRICS
    echo "$IS_PUBLIC_INSTANCE"  > /run/searxng-configure/environment/IS_PUBLIC_INSTANCE
    echo "$SECRET_KEY"          > /run/searxng-configure/environment/SECRET_KEY
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
