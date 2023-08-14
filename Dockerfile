FROM golang:1.20-bookworm as builder
WORKDIR /app
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest; \
    xcaddy build \
        --with github.com/caddyserver/caddy/v2=github.com/tianze0926/caddy/v2@custom \
        --with github.com/caddy-dns/cloudflare \
        --output caddy


FROM debian:bookworm
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&\
    apt-get install -y ca-certificates &&\
    apt-get clean
WORKDIR /app

COPY --from=builder /app/caddy .
ENV XDG_CONFIG_HOME /app/config
ENV XDG_DATA_HOME /app/data

RUN useradd --create-home --user-group abc &&\
    chown --quiet -R abc /app
USER abc

STOPSIGNAL SIGINT
CMD ["/app/caddy", "run", "--config", "/app/config.json"]
