FROM rust:slim-buster AS builder

ENV ARC="x86_64-unknown-linux-musl"
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    musl-tools
RUN rustup target add "${ARC}"
RUN cargo install mdbook --version "0.4.18" --target "${ARC}"

# FROM rust:1.61-alpine3.15
FROM alpine:3.15

# SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
COPY --from=builder /usr/local/cargo/bin/mdbook /usr/bin/mdbook

WORKDIR /book
