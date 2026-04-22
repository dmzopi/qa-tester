# Set variables
APP := qa-tester
#APP=$(shell basename -s .git $(shell git remote get-url origin))
REGISTRY=opidoc

VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

# Define target build parameters as user input, default: darwin/amd64
# Supported: https://go.dev/doc/install/source#environment
TARGET ?= darwin/amd64
TARGETOS := $(firstword $(subst /, ,$(TARGET)))
TARGETARCH := $(lastword $(subst /, ,$(TARGET)))

# Validate environment variables
ifeq (,$(findstring /,$(TARGET)))
$(error TARGET must be in format os/arch. Got: $(TARGET))
endif

# Redefine binary name for Windows
ifeq ($(TARGETOS),windows)
APP := $(APP).exe
endif

# Detect the platform/architecture the build was launched on
ifeq ($(OS),Windows_NT)
BUILDOS := windows
BUILDARCH := $(shell powershell -NoProfile -Command "[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture")
else
BUILDOS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
BUILDARCH := $(shell uname -m)
endif
# Normalize arch
ifneq (,$(filter X64 x86_64 AMD64 amd64 x64,$(BUILDARCH)))
BUILDARCH := amd64
else ifneq (,$(filter arm64 aarch64 ARM64,$(BUILDARCH)))
BUILDARCH := arm64
else
$(error Unsupported architecture: $(BUILDARCH))
endif

# Assign target image name
TARGETIMAGE=${REGISTRY}/${APP}:${VERSION}-${BUILDARCH}

print-env:
	@echo "Building '$(APP)' binary on '$(BUILDOS)/$(BUILDARCH)' for '$(TARGETOS)/$(TARGETARCH)'"

format:
	@echo "Formatting Go code..."
	gofmt -s -w ./

get:
	go get

build: print-env format get
	go env -w CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} &&\
    go build -v -o ${APP} -ldflags "-X main.appVersion=${VERSION}"

image:
	@echo "Building image ..."
	docker build . -t ${TARGETIMAGE} \
	--build-arg TARGETARCH=$(BUILDARCH)

push:
	@echo "Pushing image to registry ..."
	docker push ${TARGETIMAGE}

clean:
	@echo "Removing local image ..."
	docker rmi ${TARGETIMAGE}