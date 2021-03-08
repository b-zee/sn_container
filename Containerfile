FROM docker.io/library/rust:1.50-alpine AS builder

WORKDIR /usr/local/src

# Download sources at specific version from GitHub.
ADD https://github.com/maidsafe/sn_api/archive/v0.20.0.tar.gz         sn_api.tar.gz
ADD https://github.com/maidsafe/sn_node/archive/v0.28.2.tar.gz        sn_node.tar.gz
ADD https://github.com/maidsafe/sn_launch_tool/archive/v0.0.19.tar.gz sn_launch_tool.tar.gz

# Extract archives into their own directories (without top level directory including version).
RUN mkdir sn_api         && tar --extract --gzip --strip-components=1 --file sn_api.tar.gz         --directory sn_api/
RUN mkdir sn_node        && tar --extract --gzip --strip-components=1 --file sn_node.tar.gz        --directory sn_node/
RUN mkdir sn_launch_tool && tar --extract --gzip --strip-components=1 --file sn_launch_tool.tar.gz --directory sn_launch_tool/

# Apparently needed for some dependencies to link with musl.
RUN apk add --update musl-dev

# Shared cache for all builds.
ENV CARGO_TARGET_DIR=/usr/local/src/target

# Build the projects and install the binaries into /usr/local/bin.
RUN cargo install --root /usr/local --path sn_api/sn_cli
RUN cargo install --root /usr/local --path sn_api/sn_authd
RUN cargo install --root /usr/local --path sn_node/
RUN cargo install --root /usr/local --path sn_launch_tool/

# Create small-sized image including only the final binaries.
FROM docker.io/library/alpine:3.13

# Copy binaries from builder image.
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Copy helper script that launches network and sets up credentials for CLI.
COPY sn_start /usr/local/bin/sn_start
RUN chmod +x /usr/local/bin/sn_start

# Create user 'sn' to run the network and tools.
RUN adduser --disabled-password sn
USER sn

WORKDIR /home/sn

CMD ["sn_start"]
