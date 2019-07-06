FROM alpine:3.9.4
# Minimal container to run compiled agda executables

MAINTAINER Aidan Hamwood <ajh@tuta.io>

RUN apk add --no-cache --update libffi ncurses gmp-dev && \
    mkdir /home/user
WORKDIR /home/user
