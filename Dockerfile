FROM alpine:3.9.4

MAINTAINER Aidan Hamwood <ajh@tuta.io>


# Part 1: Haskell

RUN apk update && \
    apk add --no-cache --update --virtual .build-deps cabal ghc ghc-dev libffi-dev ncurses-dev zlib-dev && \
    apk add --no-cache --update build-base git gmp-dev gcc perl-utils wget xz

ENV PATH "/root/.local/bin:${PATH}"

RUN wget -qO- https://get.haskellstack.org/ | sh


# Part 2: Agda
# Adapted from https://github.com/JLimperg/docker-agda-stdlib

COPY stack.yaml libraries /root/.agda/

RUN git clone --depth 1 -b v2.6.0.1 https://github.com/agda/agda.git /root/.agda/src
RUN mkdir -p /root/.agda/lib && \
    git clone --depth 1 -b v1.0.1 https://github.com/agda/agda-stdlib.git /root/.agda/lib/standard-library

RUN stack --system-ghc --stack-yaml /root/.agda/stack.yaml install && \
    stack --system-ghc --stack-yaml /root/.agda/stack.yaml clean

RUN cd /root/.agda/lib/standard-library && \
    stack --resolver lts-12.14 script --package filemanip --package filepath --system-ghc -- GenerateEverything.hs && \
    mv Everything.agda src/ && \
    agda --verbose=0 src/Everything.agda && \
    rm -rf /root/.stack/build-plan /root/.stack/build-plan-cache /root/.stack/indices /root/.stack/loaded-snapshot-cache /root/.stack/setup-exe-cache /root/.stack/setup-exe-src


# Part 3: Cleanup

RUN apk del .build-deps

CMD agda
