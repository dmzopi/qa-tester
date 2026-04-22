# Set variables
APP=$(shell basename -s .git $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
REGISTRY=opidoc
TARGETIMAGE=${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

# Define mandatory target parameters as user input
TARGETOS ?= darwin#linux windows 
TARGETARCH ?= arm64#amd64

# Validate environment variables
ifeq ($(TARGETOS),)
$(error TARGETOS is not set)
endif

ifeq ($(TARGETARCH),)
$(error TARGETARCH is not set)
endif

# Detect the platform the make was launched
ifeq ($(OS),Windows_NT)
BUILDPLATFORM := windows
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
BUILDPLATFORM := linux
endif
ifeq ($(UNAME_S),Darwin)
BUILDPLATFORM := darwin
endif
endif

print-env:
	@echo "Building app binary on '$(BUILDPLATFORM)' for '$(TARGETOS)/$(TARGETARCH)'"

format:
	@echo "Formatting Go code..."
	gofmt -s -w ./

get:
	go get

build: print-env format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o app -ldflags "-X qa-tester/cmd.appVersion=${VERSION}"

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf app