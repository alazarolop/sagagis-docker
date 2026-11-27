#!/bin/bash

docker buildx build \
  --push \
  -t ghcr.io/alazarolop/sagagis:9.14.3 \
  -t ghcr.io/alazarolop/sagagis:9.14 \
  -t ghcr.io/alazarolop/sagagis:latest \
  .