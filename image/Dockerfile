FROM tailscale/tailscale:v1.30

LABEL maintainer="hollie@lika.be"

ENV CADDY_TARGET=
ENV TS_TAILNET=
ENV TS_HOSTNAME=
ENV TS_USERSPACE=true
ENV TS_STATE_DIR=/var/lib/tailscale/ 

RUN apk add --no-cache ca-certificates mailcap caddy

# Ensure Caddy can access the tailscale socket, Caddy expects it to be under /var/run/tailscale so make a symlink
RUN mkdir --parents /var/run/tailscale && ln -s /tmp/tailscaled.sock /var/run/tailscale/tailscaled.sock

# Add image version to file for traceablity
COPY VERSION /VERSION

# Add the modified startup script
COPY start.sh /usr/bin/start.sh
RUN  chmod +x /usr/bin/start.sh

# And run it
CMD  [ "start.sh" ]


