
# Gemini CLI Docker Builder

This repository contains a `Dockerfile` and a helper script to build a Docker image for the `@google/gemini-cli`.

## Building the Gemini CLI Docker Image

The `build-gemini-cli.sh` script provides a command-line interface for building the Docker image.

### Usage

1. Make the script executable:
   ```bash
   chmod +x build-gemini-cli.sh
   ```

2. Run the script with options:
   ```bash
   ./build-gemini-cli.sh [OPTIONS]
   ```

### Options

- `--version <version>`: Set the CLI version (default: `0.1.12`).
- `--image-name <name>`: Set the Docker image name (default: `acchapm1/gemini-cli`).
- `--load`: Load the Docker image locally.
- `--push`: Push the Docker image to the registry.
- `--help`: Display the help message.

You must specify at least one of `--load` or `--push`. Both can be used simultaneously.

## Dockerfile Overview

The `Dockerfile` is optimized for size and efficiency by using a multi-stage build.

- **Stage 1: `builder`**
  - Uses the `node:24-slim` image as a base.
  - Installs all necessary build-time dependencies (`g++`, `make`, `python3`, etc.).
  - Installs the specified version of `@google/gemini-cli` globally using `npm`.

- **Stage 2: Final Image**
  - Starts from a much smaller `node:24-alpine` base image.
  - Installs only essential runtime dependencies (`git`).
  - Copies the globally installed `npm` package from the `builder` stage.
  - This process ensures that the final image does not contain any of the build-time dependencies, resulting in a significantly smaller and more secure container.

This approach separates the build environment from the runtime environment, which is a best practice for creating lean and production-ready Docker images.
