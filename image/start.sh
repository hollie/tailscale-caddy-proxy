#!/bin/ash
trap 'kill -TERM $PID' TERM INT

echo "Building Caddy configfile"

echo $TS_HOSTNAME'.'$TS_TAILNET.'ts.net' > /etc/caddy/Caddyfile
echo 'reverse_proxy' $CADDY_TARGET >> /etc/caddy/Caddyfile

echo "Starting Caddy"
caddy start --config /etc/caddy/Caddyfile

echo "Starting Tailscale daemon"

tailscaled --tun=userspace-networking --state=${TAILSCALE_STATE_ARG} &

PID=$!

until tailscale up --authkey="${TAILSCALE_AUTH_KEY}" --hostname="${TS_HOSTNAME}"; do
    sleep 0.1
done

tailscale status

wait ${PID}
wait ${PID}