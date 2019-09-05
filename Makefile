APP_NAME = kubeconsole
ORG_NAME = craicoverflow
APP_CMD = ./cmd/console.go
RELEASE_TAG = $(CIRCLE_TAG)
BINARY ?= kubectl-console
BINARY_LINUX_DIR = ./dist/linux_amd64/$(BINARY)
BINARY_MACOS_DIR = ./dist/macos_amd64/$(BINARY)

# docker
IMAGE_REGISTRY = docker.io
IMAGE_LATEST_TAG = $(IMAGE_REGISTRY)/$(ORG_NAME)/$(APP_NAME):latest
IMAGE_RELEASE_TAG = $(IMAGE_REGISTRY)/$(ORG_NAME)/$(APP_NAME):$(RELEASE_TAG)

LDFLAGS=-ldflags "-w -s -X main.Version=${TAG}"
UNAME := $(shell uname)

.PHONY:
install:
ifeq ($(UNAME), Linux)
	make build-linux
	sudo mv $(BINARY_LINUX_DIR) /usr/local/bin
endif
ifeq ($(UNAME), Solaris)
	build-macos
	sudo mv $(BUILD_MACOS_DIR) /usr/local/bin
endif

.PHONY: uninstall
uninstall:
	sudo rm -rf /usr/local/bin/$(BINARY)

.PHONY: build
build: build-linux build-macos

.PHONY: build-linux
build-linux: 
	go build -o $(BINARY_LINUX_DIR) $(APP_CMD)

.PHONY: build-macos
build-macos:
	GOOS=darwin go build -o $(BINARY_MACOS_DIR) $(APP_CMD)

.PHONY: clean
clean:
	rm -rf ./dist

# format files
.PHONY: fmt
fmt:
	@echo go fmt
	go fmt $$(go list ./... | grep -v /vendor/)