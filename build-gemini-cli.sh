#!/bin/bash

# Default values
CLI_VERSION="0.1.12"
IMAGE_NAME="acchapm1/gemini-cli"
LOAD_FLAG=""
PUSH_FLAG=""

# Help message function
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -v, --version <version>    Set the CLI version (default: 0.1.12)."
  echo "  -n, --image-name <name>  Set the Docker image name (default: acchapm1/gemini-cli)."
  echo "  -l, --load                 Load the Docker image locally."
  echo "  -p, --push                 Push the Docker image to the registry."
  echo "  -h, --help                 Display this help message and exit."
  echo ""
  echo "At least one of --load or --push must be specified."
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -v|--version) CLI_VERSION="$2"; shift ;;
        -n|--image-name) IMAGE_NAME="$2"; shift ;;
        -l|--load) LOAD_FLAG="--load" ;;
        -p|--push) PUSH_FLAG="--push" ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

export CLI_VERSION

# Check if at least one of load or push is selected
if [ -z "$LOAD_FLAG" ] && [ -z "$PUSH_FLAG" ]; then
  echo "Error: You must specify at least one of --load or --push."
  show_help
  exit 1
fi

# Construct the docker build command
DOCKER_CMD=(docker buildx build --build-arg "CLI_VERSION_ARG=${CLI_VERSION}" --platform linux/arm64,linux/amd64 -t "${IMAGE_NAME}:${CLI_VERSION}" .)
if [[ -n "$LOAD_FLAG" ]]; then
  DOCKER_CMD+=("$LOAD_FLAG")
fi
if [[ -n "$PUSH_FLAG" ]]; then
  DOCKER_CMD+=("$PUSH_FLAG")
fi

echo "Running command: ${DOCKER_CMD[*]}"
"${DOCKER_CMD[@]}"
