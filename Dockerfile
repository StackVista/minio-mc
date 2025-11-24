FROM golang:1.24.9-alpine as builder

LABEL maintainer="MinIO Inc <dev@min.io>"

ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GO111MODULE=on

WORKDIR /workspace

RUN apk add --no-cache git

# Copy current source and build
COPY . /workspace

RUN go mod download && \
    go build -v -ldflags "$(go run buildscripts/gen-ldflags.go)" -o /go/bin/mc ./

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3

ARG TARGETARCH

COPY --from=builder /go/bin/mc /usr/bin/mc
COPY CREDITS /licenses/CREDITS
COPY LICENSE /licenses/LICENSE

RUN  \
     microdnf update --nodocs && \
     microdnf install ca-certificates --nodocs && \
     microdnf clean all

ENTRYPOINT ["mc"]
