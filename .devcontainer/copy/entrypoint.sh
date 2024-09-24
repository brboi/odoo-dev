#!/usr/bin/env bash
set -e

echo "Preparing environment..."
run-parts --exit-on-error --report $RESOURCES/entrypoint.d
echo "Environment prepared!"

set -- sleep infinity
echo "Starting requested command: $@"
exec "$@"
