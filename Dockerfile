# Stage 1: Builder - Installs the CLI with all necessary build tools
FROM docker.io/library/node:24-slim AS builder

ARG SANDBOX_NAME="gemini-cli-sandbox"
ARG CLI_VERSION_ARG="0.1.12"
ENV SANDBOX="$SANDBOX_NAME"
ENV CLI_VERSION=$CLI_VERSION_ARG

# Install build-time dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  make \
  g++ \
  git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set up npm global package folder and permissions
RUN mkdir -p /usr/local/share/npm-global \
  && chown -R node:node /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Switch to non-root user to install the package
USER node

# Install gemini-cli
RUN npm install -g @google/gemini-cli@$CLI_VERSION \
  && npm cache verify


# Stage 2: Final Image - Creates the lean, final image
FROM docker.io/library/node:24-alpine

ARG SANDBOX_NAME="gemini-cli-sandbox"
ARG CLI_VERSION_ARG="0.1.12"
ENV SANDBOX="$SANDBOX_NAME"
ENV CLI_VERSION=$CLI_VERSION_ARG

# Install only essential runtime dependencies.
# git is included as the CLI may interact with git repos.
# Add other tools like jq, curl, etc. here if you need them.
RUN apk add --no-cache git

# Copy the installed npm package and node_modules from the builder stage
COPY --from=builder /usr/local/share/npm-global /usr/local/share/npm-global

# Add the global bin to the path
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Switch to the non-root user
USER node

# Set home directory for the node user
WORKDIR /home/node

# Default entrypoint when none specified
CMD ["gemini"]
