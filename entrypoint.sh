#!/bin/bash
set -e

cd /opt/fxserver/server

exec ./run.sh "$@"
