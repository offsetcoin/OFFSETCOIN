# Build Geth in a stock Go builder container
FROM golang:1.13-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-offsetcoin
RUN cd /go-offsetcoin && make gosc

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-offsetcoin/build/bin/geth /usr/local/bin/

EXPOSE 9656 9656 42786 42786/udp
ENTRYPOINT ["gosc"]
