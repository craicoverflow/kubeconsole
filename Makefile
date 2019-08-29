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

# .PHONY: build-latest-image
# build-latest-image: build-linux
# 	docker build -t $(IMAGE_LATEST_TAG) --build-arg BINARY=$(BINARY_LINUX_DIR) .

# .PHONY: build-release-image
# build-release-image:
# 	docker build -t $(IMAGE_LATEST_TAG) -t $(IMAGE_RELEASE_TAG) --build-arg BINARY=$(BINARY_LINUX_64) .

# .PHONY: push-release-image
# push-release-image:
# 	@docker login --username $(QUAY_USERNAME) --password $(QUAY_PASSWORD) $(IMAGE_REGISTRY)
# 	docker push $(IMAGE_LATEST_TAG)
# 	docker push $(IMAGE_RELEASE_TAG)

# format files
.PHONY: fmt
fmt:
	@echo go fmt
	go fmt $$(go list ./... | grep -v /vendor/)