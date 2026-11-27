SAGA_IMAGE="ghcr.io/alazarolop/sagagis:latest"

saga_cmd() {
  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":"$PWD" \
    -w "$PWD" \
    "$SAGA_IMAGE" \
    saga_cmd "$@"
}