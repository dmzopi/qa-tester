FROM --platform=linux/$TARGETARCH quay.io/projectquay/golang:1.26 AS builder

ARG TARGETARCH

RUN echo "Building image for $TARGETARCH"

WORKDIR /app
COPY . .
RUN make build TARGET=linux/$TARGETARCH

FROM scratch
WORKDIR /app
COPY --from=builder /app/qa-tester .
ENTRYPOINT [ "./qa-tester" ]