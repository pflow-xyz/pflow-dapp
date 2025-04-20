# Base build stage for Gno
FROM golang:1.23-alpine AS build-gnoserve
ENV GNOROOT="/gnoroot"
ENV CGO_ENABLED=0 GOOS=linux
WORKDIR /gnoroot

# Copy and download dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod/,id=gomodcache \
    --mount=type=cache,target=/root/.cache/go-build,id=gobuildcache \
    go mod download -x

# Copy the entire working directory
COPY . .

# Build gnoserve
WORKDIR /gnoroot/cmd/gnoserve
RUN --mount=type=cache,target=/go/pkg/mod/,id=gnoserve-modcache \
    --mount=type=cache,target=/root/.cache/go-build,id=gnoserve-buildcache \
    go build -ldflags "-w -s" -o /gnoroot/build/gnoserve .

# Final stage for runtime
FROM alpine:3 AS runtime
WORKDIR /gnoroot
ENV GNOROOT="/gnoroot"
RUN apk add --no-cache ca-certificates

# Copy gnoserve binary to runtime image
COPY --from=build-gnoserve /gnoroot/build/gnoserve /usr/bin/gnoserve

# Expose any ports required by gnoserve
EXPOSE 8888

# Set the entrypoint to gnoserve
ENTRYPOINT ["/usr/bin/gnoserve"]