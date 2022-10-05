This is the repository of the Tailscale-Caddy proxy, a docker image that enables easy sharing of docker HTTP services over the Tailscale network via HTTPS.

# Rationale

I have a few docker web services I want to share with other users.

Before Tailscale this would mean opening firewall ports and enabling authentication for the users. And then you still need to worry about the fact that your services are exposed to the world. 

Tailscale enables you to share devices securely. Setup is trivial and the maintenance of who can access what is very convenient.

So, I want to share web services via Tailscale. I found that there are multiple existing solutions such as:
* the [Tailscale Docker Desktop extension](https://tailscale.com/blog/docker/), 
* the [Tailscale sidecar](https://github.com/markpash/tailscale-sidecar) by markpash 
* the official [Tailscale docker image](https://hub.docker.com/r/tailscale/tailscale).

None of those solutions fit my usage scenario so I built the solution that is available in this repo.

Compared to the other solutions this image:

* does an auto-refresh of the SSL certificates without any further required actions by the user
* supports a restart of the service container without having to restart the Tailscale/Caddy container

# Functional description

I want to be able to serve a web application to users by running a container in parallel to the container that serves the application. The side container should perform:

* the connection to the Tailscale network
* take care of serving the application via HTTPS with valid and regularly updated SSL certificates

To implement this I start from the official Tailscale docker image and I extend it with Caddy. A small script that runs when starting the container takes care of creating the right configuration file for Caddy based on the environment parameters that are set when launching the container. 

Once started the container brings up the Tailscale connection. Users with access to the Tailscale device can connect over HTTP to port 80 (which is redirected to HTTPS) or to port 443 over HTTPS directly. The Caddy reverse proxy takes care of negotiating SSL certificated with the Tailscale daemon in the container to present valid HTTPS certificates.

# Requirements

For this image to work correctly you need to enable HTTPS support and MagicDNS in your Tailscale network configuration.

# Parameters and storage

The docker image takes as input parameters:

* `TS_HOSTNAME` : the name of the host on the Tailscale network

* `TS_TAILNET`: the name of your tailnet **without** the trailing `ts.net` section.

* `CADDY_TARGET`: the name and port of the service you want to connect to.

You also want to declare a permanent volume to store the Tailscale credentials so that those survive a rebuild of the container. The Tailscale configuration is located in the folder `/var/lib/tailscale` in the container.

# Practical use

Say you have an example service called 'whoami' that is a simple webserver listening on port 80 and you want to expose it via Tailscale.

We want to keep the network traffic between this container and the Tailscale proxy separated from the default docker network, so declare a network. Attach the whoami container to that network. Declare a container of the `hollie/tailscale-caddy-proxy` image next to it, attach it also to the same network and enter the right environmental parameters for the Tailscale and Caddy configuration.

The resulting docker compose file looks like:

```docker
version: '3'

networks:
  tailscale_proxy_example:
    external: false

volumes:
  tailscale-whoami-state:

services:

  whoami:
    image: traefik/whoami
    networks:
     - tailscale_proxy_example

  tailscale-whoami-proxy:
    image: hollie/tailscale-caddy-proxy:buildx-latest
    volumes:
      - tailscale-whoami-state:/var/lib/tailscale # Persist the tailscale state directory
    environment:
      - TS_HOSTNAME=tailscale-example    # Hostname you want this instance to have on the tailscale network
      - TS_TAILNET=tailnet-XXXX     # Fill in your tailnet name here without the .ts.net suffix!
      - CADDY_TARGET=whoami:80        # Target service and port
    restart: on-failure
    init: true
    networks:
     - tailscale_proxy_example
```

Run `docker-compose up` and visit the link that is printed in the terminal to authenticate the machine to your Tailscale network. Disable key expiry via the Tailscale settings page for this host and restart the containers with `docker compose up -d`. 

All set!

# Acknowledgements

Thanks to lpasselin for his [example code](https://github.com/lpasselin/tailscale-docker) that shows how to extend the default Tailscale image.
