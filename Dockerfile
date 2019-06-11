FROM alpine:3.9.4
# Adapted from:
# https://github.com/ajhamwood/idris-alpine
# https://github.com/JLimperg/docker-agda-stdlib
# https://hub.docker.com/r/qualified/agda

MAINTAINER Aidan Hamwood <ajh@tuta.io>


# Part 1: Haskell

RUN apk update && \
    apk add --no-cache --update --virtual .build-deps libffi-dev ncurses-dev alpine-sdk musl-dev zlib-dev && \
    apk add --no-cache --update libffi ncurses gmp-dev ghc ghc-dev cabal

ENV PATH "/root/.local/bin:${PATH}"

RUN wget -qO- https://get.haskellstack.org/ | sh


# Part 2: Agda

WORKDIR /root/.agda
COPY stack.yaml ./

RUN echo "/root/.agda/lib/standard-library/standard-library.agda-lib" > libraries && \
    echo "standard-library" > defaults

RUN git clone --depth 1 -b v2.6.0.1 https://github.com/agda/agda.git src && \
    mkdir -p lib && \
    git clone --depth 1 -b v1.0.1 https://github.com/agda/agda-stdlib.git lib/standard-library

RUN stack config set system-ghc --global true && \
    stack install && \
    stack clean

RUN cd lib/standard-library && \
    stack --resolver lts-12.14 script -- GenerateEverything.hs && \
    mv Everything.agda src/ && \
    agda -i. -isrc src/Everything.agda


# Part 3: Cleanup

RUN cd /root/.stack && rm -rf build-plan build-plan-cache indices loaded-snapshot-cache setup-exe-cache setup-exe-src && \
    apk del .build-deps

RUN mkdir /home/user
WORKDIR /home/user
ENTRYPOINT ["stack", "--stack-yaml", "/root/.agda/stack.yaml", "exec", "--"]
