#!/bin/ash
trap 'kill -TERM $PID' TERM INT

echo "This is Tailscale-Caddy-proxy version"
tailscale --version

if [ ! -z "$SKIP_CADDYFILE_GENERATION" ]; then
	echo "Skipping Caddyfile generation as requested via environment"
else
	echo "Building Caddy configfile"

	echo $TS_HOSTNAME'.'$TS_TAILNET.'ts.net' >/etc/caddy/Caddyfile
	echo 'reverse_proxy' $CADDY_TARGET >>/etc/caddy/Caddyfile
fi

echo "Starting Caddy"
caddy start --config /etc/caddy/Caddyfile

echo "Starting Tailscale"

exec /usr/local/bin/containerboot
