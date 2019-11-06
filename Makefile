APP_NAME = kubeconsole
ORG_NAME = craicoverflow
APP_CMD = ./cmd/console.go
RELEASE_TAG = $(CIRCLE_TAG)
BINARY ?= console
TAR_LINUX_NAME = linux_amd64
TAR_MACOS_NAME = macos_darwin
BINARY_LINUX_DIR = ./dist/$(TAR_LINUX_NAME)
BINARY_MACOS_DIR = ./dist/$(TAR_MACOS_NAME)

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
	sudo cp $(BINARY_LINUX_DIR) /usr/local/bin
endif
ifeq ($(UNAME), Darwin)
	make build-macos
	sudo cp $(BINARY_MACOS_DIR) /usr/local/bin
endif

.PHONY:
install-oc:
ifeq ($(UNAME), Linux)
	make build-linux
	sudo cp $(BINARY_LINUX_DIR)/$(BINARY) /usr/local/bin
	sudo cp $(BINARY_LINUX_DIR)/$(BINARY) /usr/local/bin/oc-console
endif
ifeq ($(UNAME), Darwin)
	make build-macos
	sudo cp $(BINARY_MACOS_DIR) /usr/local/bin
	sudo cp $(BINARY_MACOS_DIR) /usr/local/bin/oc-console
endif

.PHONY: uninstall
uninstall:
	sudo rm -rf /usr/local/bin/$(BINARY)

.PHONY: clean-dist
clean-dist:
	rm -rf dist

.PHONY: build
build: clean-dist build-linux build-macos compress-linux compress-macos

.PHONY: build-linux
build-linux: 
	go build -o $(BINARY_LINUX_DIR)/$(BINARY) $(APP_CMD)

.PHONY: compress-linux
compress-linux:
	cd dist; tar -czvf $(TAR_LINUX_NAME).tar.gz $(TAR_LINUX_NAME)

.PHONY: compress-macos
compress-macos:
	cd dist; tar -czvf $(TAR_MACOS_NAME).tar.gz $(TAR_MACOS_NAME)

.PHONY: build-macos
build-macos:
	GOOS=darwin go build -o $(BINARY_MACOS_DIR)/$(BINARY) $(APP_CMD)

.PHONY: clean
clean:
	rm -rf ./dist

# format files
.PHONY: fmt
fmt:
	@echo go fmt
	go fmt $$(go list ./... | grep -v /vendor/)