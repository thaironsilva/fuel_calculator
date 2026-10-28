# syntax=docker/dockerfile:1

FROM elixir:1.19.4-slim

ENV MIX_ENV=prod \
    PHX_SERVER=true \
    PORT=4000 \
    LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       git \
       openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY . .

RUN mix compile
RUN mix assets.deploy

EXPOSE 4000

CMD ["/bin/sh", "-c", "export SECRET_KEY_BASE=\"${SECRET_KEY_BASE:-$(openssl rand -base64 48)}\"; exec mix phx.server"]
