GOCMD := go
REVISION := $(shell git log -n1 --pretty=format:%h)
FULL_REVISION := $(shell git log -n1 --pretty=format:%H)
TAGS := dev
LDFLAGS := -X main.revision $(FULL_REVISION)

export GOPATH := $(PWD):$(PWD)/gopath
export PATH := $(PWD)/bin:$(PWD)/gopath/bin:$(PATH)

.PHONY: all
all:
	$(GOCMD) install -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -v ./...

.PHONY: race
race:
	$(GOCMD) install -race -v `$(GOCMD) list -f '{{if eq .Name "main"}}{{.ImportPath}}{{end}}' ./...`

.PHONY: test
test:
	go test ./...

.PHONY: test-race
test-race:
	go test -race ./...

TEST=$(subst $(space),$(newline),$(shell cd src && $(GOCMD) list -f '{{if or .TestGoFiles .XTestGoFiles}}{{.Dir}}{{end}}' ./...))

.PHONY: test-compile
test-compile: $(addsuffix .test-compile, $(TEST))

%.test-compile: all
	cd $* && $(GOCMD) test -compiler=$(COMPILER) -p 1 -v -c .

.PHONY: clean
clean:
	$(RM) -rf bin pkg

.PHONY: gofmt
gofmt:
	$(GOCMD) fmt ./...
