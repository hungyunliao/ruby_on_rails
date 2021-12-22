#!/bin/bash
set -e

rm -f /ror/tmp/pids/server.pid

exec "$@"