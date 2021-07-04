# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gexp android ios gexp-cross evm all test clean
.PHONY: gexp-linux gexp-linux-386 gexp-linux-amd64 gexp-linux-mips64 gexp-linux-mips64le
.PHONY: gexp-linux-arm gexp-linux-arm-5 gexp-linux-arm-6 gexp-linux-arm-7 gexp-linux-arm64
.PHONY: gexp-darwin gexp-darwin-386 gexp-darwin-amd64
.PHONY: gexp-windows gexp-windows-386 gexp-windows-amd64

GOBIN = ./build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run

gexp:
	$(GORUN) build/ci.go install ./cmd/gexp
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gexp\" to launch gexp."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gexp.aar\" to use the library."

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gexp.framework\" to use the library."

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

gexp-cross: gexp-linux gexp-darwin gexp-windows gexp-android gexp-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gexp-*

gexp-linux: gexp-linux-386 gexp-linux-amd64 gexp-linux-arm gexp-linux-mips64 gexp-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-*

gexp-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gexp
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep 386

gexp-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gexp
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep amd64

gexp-linux-arm: gexp-linux-arm-5 gexp-linux-arm-6 gexp-linux-arm-7 gexp-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep arm

gexp-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gexp
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep arm-5

gexp-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gexp
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep arm-6

gexp-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gexp
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep arm-7

gexp-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gexp
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep arm64

gexp-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gexp
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep mips

gexp-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gexp
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep mipsle

gexp-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gexp
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep mips64

gexp-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gexp
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gexp-linux-* | grep mips64le

gexp-darwin: gexp-darwin-386 gexp-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gexp-darwin-*

gexp-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gexp
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-darwin-* | grep 386

gexp-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gexp
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-darwin-* | grep amd64

gexp-windows: gexp-windows-386 gexp-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gexp-windows-*

gexp-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gexp
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-windows-* | grep 386

gexp-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gexp
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gexp-windows-* | grep amd64
