# Copyright 2016 The Plot Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

.PHONY:	all clean cover cpu editor internalError later mem nuke todo edit

grep=--include=*.go --include=*.l --include=*.y --include=*.yy

all: editor
	go vet || true
	golint || true
	make todo
	unused . || true
	gosimple . || true

clean:
	go clean
	rm -f *~ cpu.test mem.test

cover:
	t=$(shell tempfile) ; go test -coverprofile $$t && go tool cover -html $$t && unlink $$t

cpu:
	go test -c -o cpu.test
	./cpu.test -noerr -test.cpuprofile cpu.out
	go tool pprof --lines cpu.test cpu.out

edit:
	gvim -p Makefile scanner.l parser.yy *.go

editor: scanner.go parser.go
	gofmt -l -s -w *.go
	go test -i
	go test ./... 2>&1 | tee log
	go install

internalError:
	egrep -ho '"internal error.*"' *.go | sort | cat -n

later:
	@grep -n $(grep) LATER * || true
	@grep -n $(grep) MAYBE * || true

mem:
	go test -c -o mem.test
	./mem.test -test.bench . -test.memprofile mem.out
	go tool pprof --lines --web --alloc_space mem.test mem.out

parser.go scanner.go: parser.yy scanner.l xerrors
	go generate 2>&1 | tee log-generate

nuke: clean
	go clean -i

todo:
	@grep -nr $(grep) ^[[:space:]]*_[[:space:]]*=[[:space:]][[:alpha:]][[:alnum:]]* * || true
	@grep -nr $(grep) TODO * || true
	@grep -nr $(grep) BUG * || true
	@grep -nr $(grep) [^[:alpha:]]println * || true
