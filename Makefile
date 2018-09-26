
all: test install
	@echo "Done"

install:
	go install github.com/jrmarkle/ffjson

deps:

fmt:
	go fmt github.com/jrmarkle/ffjson/...

cov:
	# TODO: cleanup this make target.
	mkdir -p coverage
	rm -f coverage/*.html
	# gocov test github.com/jrmarkle/ffjson/generator | gocov-html > coverage/generator.html
	# gocov test github.com/jrmarkle/ffjson/inception | gocov-html > coverage/inception.html
	gocov test github.com/jrmarkle/ffjson/fflib/v1 | gocov-html > coverage/fflib.html
	@echo "coverage written"

test-core:
	go test -v github.com/jrmarkle/ffjson/fflib/v1 github.com/jrmarkle/ffjson/generator github.com/jrmarkle/ffjson/inception

test: ffize test-core
	go test -v github.com/jrmarkle/ffjson/tests/...

ffize: install
	ffjson -force-regenerate tests/ff.go
	ffjson -force-regenerate tests/goser/ff/goser.go
	ffjson -force-regenerate tests/go.stripe/ff/customer.go
	ffjson -force-regenerate -reset-fields tests/types/ff/everything.go
	ffjson -force-regenerate tests/number/ff/number.go

lint: ffize
	go get github.com/golang/lint/golint
	golint --set_exit_status tests/...

bench: ffize all
	go test -v -benchmem -bench MarshalJSON  github.com/jrmarkle/ffjson/tests
	go test -v -benchmem -bench MarshalJSON  github.com/jrmarkle/ffjson/tests/goser github.com/jrmarkle/ffjson/tests/go.stripe
	go test -v -benchmem -bench UnmarshalJSON  github.com/jrmarkle/ffjson/tests/goser github.com/jrmarkle/ffjson/tests/go.stripe

clean:
	go clean -i github.com/jrmarkle/ffjson/...
	find . -name '*_ffjson.go' -delete
	find . -name 'ffjson-inception*' -delete

.PHONY: deps clean test fmt install all
