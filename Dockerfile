FROM alpine:3.9.4
# Adapted from:
# https://github.com/ajhamwood/idris-alpine
# https://github.com/JLimperg/docker-agda-stdlib
# https://hub.docker.com/r/qualified/agda

MAINTAINER Aidan Hamwood <ajh@tuta.io>


ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /root/.agda
COPY stack.yaml ./


# Part 1: Haskell

RUN apk add --no-cache --update --virtual .build-deps libffi-dev ncurses-dev alpine-sdk zlib-dev && \
    apk add --no-cache --update libffi ncurses musl-dev gmp-dev ghc ghc-dev cabal && \
#
    wget -qO- https://get.haskellstack.org/ | sh && \
#
#
# Part 2: Agda
#
    echo "/root/.agda/lib/standard-library/standard-library.agda-lib" > libraries && \
    echo "standard-library" > defaults && \
#
    git clone --depth 1 -b v2.6.0.1 https://github.com/agda/agda.git src && \
    mkdir -p lib && \
    git clone --depth 1 -b v1.0.1 https://github.com/agda/agda-stdlib.git lib/standard-library && \
#
    stack config set system-ghc --global true && \
    stack install && \
    stack clean && \
#
    cd lib/standard-library && \
    stack --resolver lts-12.14 script -- GenerateEverything.hs && \
    mv Everything.agda src/ && \
    agda -i. -isrc src/Everything.agda && \
#
#
# Part 3: Cleanup
#
    cd /root/.stack && rm -rf build-plan build-plan-cache indices loaded-snapshot-cache setup-exe-cache setup-exe-src && \
    apk del .build-deps && \
#
    mkdir /home/user
WORKDIR /home/user
ENTRYPOINT ["stack", "--stack-yaml", "/root/.agda/stack.yaml", "exec", "--"]
