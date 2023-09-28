#!/bin/ash
trap 'kill -TERM $PID' TERM INT

echo "This is Tailscale-Caddy-proxy version"
tailscale --version

echo "Building Caddy configfile"

echo $TS_HOSTNAME'.'$TS_TAILNET.'ts.net' > /etc/caddy/Caddyfile
echo 'reverse_proxy' $CADDY_TARGET >> /etc/caddy/Caddyfile

echo "Starting Caddy"
caddy start --config /etc/caddy/Caddyfile

echo "Starting Tailscale"

export TS_EXTRA_ARGS=--hostname="${TS_HOSTNAME} ${TS_EXTRA_ARGS}"
echo "Note: set TS_EXTRA_ARGS to " $TS_EXTRA_ARGS
/usr/local/bin/containerboot
