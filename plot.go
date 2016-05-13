// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:generate go run generate.go
//go:generate golex -o scanner.go scanner.l
//go:generate go run generate.go -2

// Package plot wraps Gnuplot, the portable command-line driven graphing
// utility for Linux, OS/2, MS Windows, OSX, VMS, and many other platforms.
//
// See also: http://www.gnuplot.info/
//
// Executing scripts
//
// Use the File and Script functions to execute a Gnuplot script in a file or
// []byte respectively.
//
// Parsing scripts
//
// Use the Parse, ParseString and ParseFile functions to parse a Gnuplot script
// comming from an io.Reader, string and named file respectively.
//
// The grammar of Gnuplot scipts is not context free and is defined, at least
// partially, by implementation. It's impossible to create a proper LALR(1)
// grammar for a yacc based parser.  The parser provided by this package
// approximates the Gnuplot grammar. It will reject some Gnuplot scripts which
// are accepted by the Gnuplot program and it will accept some other scripts
// which are rejected by the same.  Between those extremes are many, if not
// most, scripts that the parser recognizes correctly.
//
// Keywords, like 'with', 'lines' etc., can be shortened as long as they're
// unambiguous, so for example 'plot sin(x) w li' is a valid Gnuplot statement.
// The parser in this package handles shortened keywords only partially.  Some
// scripts rejected by the parser will be accepted when modified to use full,
// non-shortened keywords.
//
// Please share your Gnuplot scripts which the parser does not accept, or
// incorrectly accepts, and fill a report at the project issue tracker.
package plot

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"

	"github.com/cznic/mathutil"
	"github.com/cznic/xc"
)

var (
	gnuplotPath, gnuplotPathErr = exec.LookPath("gnuplot")
)

// Script executes the script in src and returns the combined output from
// gnuplot.
func Script(src []byte) ([]byte, error) {
	if err := gnuplotPathErr; err != nil {
		return nil, err
	}

	f, err := ioutil.TempFile("", "plot-")
	if err != nil {
		return nil, err
	}

	if err := ioutil.WriteFile(f.Name(), src, 0600); err != nil {
		return nil, err
	}

	defer os.Remove(f.Name())

	return File(f.Name())
}

// File executes the script in file name and returns the combined output from
// gnuplot.
func File(name string) ([]byte, error) {
	if err := gnuplotPathErr; err != nil {
		return nil, err
	}

	return exec.Command(gnuplotPath, name).CombinedOutput()
}

func exampleAST(rule int, src string) interface{} {
	lx, _ := parseString(fmt.Sprintf("example%v.go", rule), src, exampleRule(rule))
	return lx.example
}

func parseString(nm, src string, options ...Option) (*lexer, error) {
	return parse(nm, len(src)+1, bytes.NewBufferString(src), options...)
}

func parse(nm string, sz int, r io.Reader, options ...Option) (*lexer, error) {
	rr, ok := r.(io.RuneReader)
	if !ok {
		rr = bufio.NewReader(r)
	}

	preproc := newPreprocessor(rr)
	lx := newLexer(nm, sz, preproc)
	preproc.lx = lx.Lexer
	for _, o := range options {
		if err := o(&lx.opts); err != nil {
			return lx, err
		}
	}

	if n := lx.opts.yyDebug; n > 0 {
		yyDebug = n
	}
	y := yyParse(lx)
	err := lx.report.Errors(true)
	if y > 0 && err == nil {
		panic("internal error")
	}

	return lx, err
}

// Option allows to amend the parser behavior.
type Option func(*opts) error

type opts struct {
	enableCommandSubstitution bool
	exampleRule               int
	readlineHook              func([]xc.Token)
	yyDebug                   int
}

func exampleRule(rule int) Option {
	return func(o *opts) error {
		o.exampleRule = rule
		return nil
	}
}

func readlineHook(f func([]xc.Token)) Option {
	return func(o *opts) error {
		o.readlineHook = f
		return nil
	}
}

// EnableCommandSubstitution enables command substitution by executing strings
// between backticks.  Command substitution should never be enabled for
// untrusted sources.
func EnableCommandSubstitution() Option {
	return func(o *opts) error {
		o.enableCommandSubstitution = true
		return nil
	}
}

// YyDebug sets the parser debug level.
func YyDebug(level int) Option {
	return func(o *opts) error {
		o.yyDebug = level
		return nil
	}
}

// Parse parses a GnuPlot script in r with assumed name nm and size sz and
// returns the resulting AST and an error, if any. The error, if non nil, is
// possibly a scanner.ErrorList.
func Parse(nm string, sz int, r io.Reader, options ...Option) (*AST, error) {
	lx, err := parse(nm, sz, r, options...)
	return lx.ast, err
}

// ParseString parses a GnuPlot script in src with asssumed name nm and returns
// the resulting AST and an error, if any. The error, if non nil, is possibly a
// scanner.ErrorList.
func ParseString(nm, src string, options ...Option) (*AST, error) {
	r := bytes.NewBufferString(src)
	lx, err := parse(nm, len(src), r, options...)
	return lx.ast, err
}

// ParseFile parses a GnuPlot script in file name and returns the resulting AST
// and an error, if any. The error, if non nil, is possibly a
// scanner.ErrorList.
func ParseFile(name string, options ...Option) (*AST, error) {
	f, err := os.Open(name)
	if err != nil {
		return nil, err
	}

	fi, err := f.Stat()
	if err != nil {
		return nil, err
	}

	sz := fi.Size()
	if sz > mathutil.MaxInt {
		return nil, fmt.Errorf("file too big")
	}

	return Parse(name, int(sz), f, options...)
}
