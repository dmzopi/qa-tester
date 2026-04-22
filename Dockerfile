FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Building Image on $BUILDPLATFORM for $TARGETPLATFORM"

WORKDIR /app
COPY . .
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/app .
ENTRYPOINT [ "/app" ]

