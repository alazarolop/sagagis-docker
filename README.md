# SAGA GIS Docker

[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io-blue)](https://github.com/alazarolop/sagagis-docker/pkgs/container/sagagis)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Containerized distribution of **[SAGA GIS (System for Automated Geoscientific Analyses)](http://www.saga-gis.org/)** designed to act as a drop-in replacement for a traditional local installation.

This image allows running `saga_cmd` inside an isolated and reproducible Docker environment while preserving a workflow similar to using a native SAGA GIS installation. It is useful for sandboxed environments, reproducible scientific workflows, CI/CD pipelines, and systems where installing GIS dependencies directly on the host is undesirable.

---

## Features

- Built directly from official SAGA GIS source code.
- Multi-stage Docker build to reduce final image size.
- Designed as a sandboxed replacement for a locally installed `saga_cmd`.
- Reproducible execution environment.
- Versioned container releases.
- Published through GitHub Container Registry (GHCR).
- Suitable for local execution, automation workflows, CI/CD, and scientific computing environments.

---

## Available Images

```bash
ghcr.io/alazarolop/sagagis:latest
ghcr.io/alazarolop/sagagis:9.14
ghcr.io/alazarolop/sagagis:9.14.3
```

### Tag Policy

| Tag | Description |
|------|-------------|
| `latest` | Latest recommended release |
| `9.14` | Latest release within the 9.14 series |
| `9.14.3` | Exact reproducible release |

---

## Quick Start

Display the installed SAGA GIS version:

```bash
docker run --rm ghcr.io/alazarolop/sagagis:latest saga_cmd --version
```

Run SAGA GIS within the current working directory:

```bash
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":"$PWD" \
    -w "$PWD" \
    ghcr.io/alazarolop/sagagis:latest \
    saga_cmd
```

---

## Using as a Local Command

To use the container as if SAGA GIS were installed natively on the host system, install a lightweight wrapper script in `/usr/local/bin`.

Create the wrapper:

```bash
sudo tee /usr/local/bin/saga_cmd > /dev/null <<'EOF'
#!/usr/bin/env bash

docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":"$PWD" \
    -w "$PWD" \
    ghcr.io/alazarolop/sagagis:latest \
    saga_cmd "$@"
EOF

sudo chmod +x /usr/local/bin/saga_cmd
```

Verify the installation:

```bash
saga_cmd --version
```

Once installed, SAGA GIS can be used exactly as if it were available locally:

```bash
saga_cmd --version

saga_cmd ta_morphometry 0

saga_cmd ta_lighting 0 \
    -DEM dem.tif \
    -SHADE hillshade.tif
```

You can also make it available to all users by copying the `sagagis.sh` file to `/etc/profile.d/`.

---

## Building the Image

Build and publish the image manually:

```bash
docker buildx build \
    --push \
    -t ghcr.io/alazarolop/sagagis:9.14.3 \
    -t ghcr.io/alazarolop/sagagis:9.14 \
    -t ghcr.io/alazarolop/sagagis:latest \
    .
```

Or use the provided helper script:

```bash
./scripts/release.sh
```

---

## Credits

This repository is based on:

- https://github.com/chbrandt/docker-sagagis

The packaged software itself comes from:

- SAGA GIS (System for Automated Geoscientific Analyses)

Please refer to the upstream [SAGA GIS project](https://sourceforge.net/projects/saga-gis/) for documentation, scientific references, and software details.

---

## License

The Dockerfiles, build scripts, wrapper scripts, and repository contents are licensed under the terms of the **GNU General Public License v3.0 or later (GPL-3.0-or-later)**.

See the [LICENSE](LICENSE) file for details.

### Third-Party Software

This repository packages SAGA GIS but does not alter its original copyright notices or licensing conditions.
SAGA GIS remains subject to its own licensing terms as provided by the upstream project.