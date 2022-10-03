FROM tailscale/tailscale:v1.30

ENV CADDY_TARGET=
ENV TS_TAILNET=
ENV TS_HOSTNAME=

RUN apk add --no-cache ca-certificates mailcap caddy

RUN mkdir --parents /var/run/tailscale && ln -s /tmp/tailscaled.sock /var/run/tailscale/tailscaled.sock

COPY start.sh /usr/bin/start.sh
RUN  chmod +x /usr/bin/start.sh
CMD  "start.sh"


