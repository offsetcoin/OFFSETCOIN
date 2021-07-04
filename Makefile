# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gosc android ios gosc-cross evm all test clean
.PHONY: gosc-linux gosc-linux-386 gosc-linux-amd64 gosc-linux-mips64 gosc-linux-mips64le
.PHONY: gosc-linux-arm gosc-linux-arm-5 gosc-linux-arm-6 gosc-linux-arm-7 gosc-linux-arm64
.PHONY: gosc-darwin gosc-darwin-386 gosc-darwin-amd64
.PHONY: gosc-windows gosc-windows-386 gosc-windows-amd64

GOBIN = ./build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run

gosc:
	$(GORUN) build/ci.go install ./cmd/gosc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gosc\" to launch gosc."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gosc.aar\" to use the library."

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gosc.framework\" to use the library."

test: all
	$(GORUN) build/ci.go test

lint: ## Run linters.
	$(GORUN) build/ci.go lint

clean:
	env GO111MODULE=on go clean -cache
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gosc-cross: gosc-linux gosc-darwin gosc-windows gosc-android gosc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gosc-*

gosc-linux: gosc-linux-386 gosc-linux-amd64 gosc-linux-arm gosc-linux-mips64 gosc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-*

gosc-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gosc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep 386

gosc-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gosc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep amd64

gosc-linux-arm: gosc-linux-arm-5 gosc-linux-arm-6 gosc-linux-arm-7 gosc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep arm

gosc-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gosc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep arm-5

gosc-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gosc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep arm-6

gosc-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gosc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep arm-7

gosc-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gosc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep arm64

gosc-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gosc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep mips

gosc-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gosc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep mipsle

gosc-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gosc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep mips64

gosc-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gosc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gosc-linux-* | grep mips64le

gosc-darwin: gosc-darwin-386 gosc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gosc-darwin-*

gosc-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gosc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-darwin-* | grep 386

gosc-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gosc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-darwin-* | grep amd64

gosc-windows: gosc-windows-386 gosc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gosc-windows-*

gosc-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gosc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-windows-* | grep 386

gosc-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gosc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gosc-windows-* | grep amd64
