# Stage 1: Use gnoland container to extract /gnoroot
FROM ghcr.io/gnolang/gno/gnoland:chain-test6 as gnoland

FROM golang:1.24.2-alpine3.21

# Set environment variables
ENV GNOROOT="/gnoroot"
ENV CGO_ENABLED=0 GOOS=linux

# Copy /gnoroot from the gnoland container
COPY --from=gnoland /gnoroot /gnoroot

# Set the working directory
WORKDIR /gnoroot/dapp

# Copy and download dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod/,id=gomodcache \
    --mount=type=cache,target=/root/.cache/go-build,id=gobuildcache \
    go mod download -x

# Copy the entire working directory
COPY . .

# Build gnoserve
WORKDIR /gnoroot/dapp/cmd/gnoserve
RUN --mount=type=cache,target=/go/pkg/mod/,id=gnoserve-modcache \
    --mount=type=cache,target=/root/.cache/go-build,id=gnoserve-buildcache \
    go build -ldflags "-w -s" -o /usr/bin/gnoserve .

# Set the working directory for gnoserve
WORKDIR /gnoroot/dapp
ENV GNO_SERVE="/gnoroot/dapp/examples"

# Expose any ports required by gnoserve
EXPOSE 8888

# Set the entrypoint to gnoserve
ENTRYPOINT ["/usr/bin/gnoserve"]