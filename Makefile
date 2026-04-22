# Set variables
APP=$(shell basename -s .git $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
REGISTRY=opidoc

# Define target parameters as user input, default darwin/amd64
# Supported: https://go.dev/doc/install/source#environment
# Popular:
# TARGETOS = darwin linux windows 
# TARGETARCH = arm64 amd64
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

# Assign target image name
TARGETIMAGE=${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

# Detect the platform/arch myself was launched
ifeq ($(OS),Windows_NT)
BUILDOS := windows
BUILDARCH := $(shell powershell -NoProfile -Command "[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture")
else
BUILDOS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
BUILDARCH := $(shell uname -m)
endif
# Normalize arch
ifeq ($(filter X64 x86_64 aarch64 ,$(BUILDARCH)),)
else
BUILDARCH := amd64
endif

print-env:
	@echo "Building '$(APP)' binary on '$(BUILDOS)/$(BUILDARCH)' for '$(TARGETOS)/$(TARGETARCH)'"
format:
	@echo "Formatting Go code..."
	gofmt -s -w ./

get:
	go get

build: print-env format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -v -o ${APP} -ldflags "-X ${APP}/cmd.appVersion=${VERSION}"

image:
	docker build . -t ${TARGETIMAGE} \
	--build-arg TARGETARCH=$(TARGETARCH)

push:
	docker push ${TARGETIMAGE}

clean:
	docker rmi ${TARGETIMAGE}