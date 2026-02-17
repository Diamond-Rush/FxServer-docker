#!/bin/bash
set -e

# permission
chown -R fxserver:fxserver /opt/fxserver/server-data
chown -R fxserver:fxserver /opt/fxserver/server/txData

# Switch to server binaries directory
cd /opt/fxserver/server

# Run host script as fxserver user
exec su fxserver -c "./run.sh $*"
