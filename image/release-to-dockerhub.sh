set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=hollie
# image name
IMAGE=tailscale-caddy-proxy
# platforms
PLATFORM=linux/arm64,linux/amd64,linux/arm/v7
# bump version
#docker run --rm -v "$PWD":/app treeder/bump patch
version=`awk -F "=" '/TAILSCALE_VERSION=/{print $NF}' Dockerfile`
echo "Building version: $version"
# run build
docker buildx build --platform $PLATFORM -t $USERNAME/$IMAGE:latest -t $USERNAME/$IMAGE:v$version --push .
# tag it
git add -A
git commit -m "Tailscale-Caddy-proxy version $version"
git tag -a "dockerhub-$version" -m "Tailscale-Caddy-proxy version $version"
git push
git push --tags

