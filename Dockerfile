FROM --platform=linux/$TARGETARCH quay.io/projectquay/golang:1.26 AS builder

ARG TARGETARCH

RUN echo "Building Image to run at $TARGETARCH"

WORKDIR /app
COPY . .
RUN make build TARGET=linux/$TARGETARCH

FROM scratch
WORKDIR /
COPY --from=builder /app .
ENTRYPOINT [ "/app" ]
