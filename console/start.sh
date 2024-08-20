#!/bin/sh

if [ "$ENVIRONMENT" = "production" ]; then
    nginx -g 'daemon off;'
else
    pnpm run prebuild && ember serve
fi
