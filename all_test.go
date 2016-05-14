// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package plot

import (
	"bytes"
	"flag"
	"fmt"
	"go/scanner"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"testing"

	"github.com/cznic/xc"
)

func caller(s string, va ...interface{}) {
	if s == "" {
		s = strings.Repeat("%v ", len(va))
	}
	_, fn, fl, _ := runtime.Caller(2)
	fmt.Fprintf(os.Stderr, "caller: %s:%d: ", path.Base(fn), fl)
	fmt.Fprintf(os.Stderr, s, va...)
	fmt.Fprintln(os.Stderr)
	_, fn, fl, _ = runtime.Caller(1)
	fmt.Fprintf(os.Stderr, "\tcallee: %s:%d: ", path.Base(fn), fl)
	fmt.Fprintln(os.Stderr)
	os.Stderr.Sync()
}

func dbg(s string, va ...interface{}) {
	if s == "" {
		s = strings.Repeat("%v ", len(va))
	}
	_, fn, fl, _ := runtime.Caller(1)
	fmt.Fprintf(os.Stderr, "dbg %s:%d: ", path.Base(fn), fl)
	fmt.Fprintf(os.Stderr, s, va...)
	fmt.Fprintln(os.Stderr)
	os.Stderr.Sync()
}

func TODO(...interface{}) string {
	_, fn, fl, _ := runtime.Caller(1)
	return fmt.Sprintf("TODO: %s:%d:\n", path.Base(fn), fl)
}

func use(...interface{}) {}

func init() {
	flag.IntVar(&yyDebug, "yydebug", 0, "")
}

// ============================================================================

var (
	oRE       = flag.String("re", "", "")
	oReadline = flag.Bool("readline", false, "")
)

func errString(err error) string {
	var b bytes.Buffer
	scanner.PrintError(&b, err)
	return strings.TrimSpace(b.String())
}

func TestPreprocessor(t *testing.T) {
	const src = `
c\
d'a';
cd 'b'
`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	t.Log(PrettyString(ast))
}

func TestCommandSubstitution(t *testing.T) {
	const src = "c\\\nd'a';`echo cd \"'xyz'\"`;cd \"b\x41\";cd 'foo`echo -n bar`baz`echo -n 123`qux';cd \"foo`echo -n bar`baz`echo -n 123`qux\""
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r, EnableCommandSubstitution())
	if err != nil {
		t.Fatal(errString(err))
	}

	t.Log(PrettyString(ast))
}

func TestMacro(t *testing.T) {
	const src = `foo = "cd"
	@foo 'y'
`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	t.Log(PrettyString(ast))
}

func TestParser(t *testing.T) {
	const errLimit = 10

	var buf []byte
	readline := func(a []xc.Token) {
		buf = buf[:0]
		for _, v := range a {
			buf = append(buf, v.S()...)
			buf = append(buf, ' ')
		}
		fmt.Printf("%s\n", bytes.TrimSpace(buf))
	}

	var opts []Option
	if *oReadline {
		opts = append(opts, readlineHook(readline))
	}
	n := 0
	if err := filepath.Walk("testdata", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		switch filepath.Ext(path) {
		case ".gp", ".dem", ".rot", ".fnc", ".par", ".inc", ".cor":
			// ok
		default:
			return nil
		}

		if re := *oRE; re != "" {
			ok, err := regexp.MatchString(re, path)
			if err != nil {
				t.Fatal(err)
			}

			if !ok {
				return nil
			}

			t.Log(path)
		}

		_, err = ParseFile(path, opts...)
		if err != nil {
			s := errString(err)
			n += strings.Count(s, "\n") + 1
			switch {
			case n >= errLimit:
				t.Fatal(errString(err))
			default:
				t.Error(errString(err))
			}
		}

		return nil
	}); err != nil {
		t.Fatal(errString(err))
	}
}

func TestNamedDataBlock(t *testing.T) {
	const src = `$foo << EOF
a
EOF
print ""
`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	ndb := ast.StatementList.Statement.NamedDataBlock
	if g, e := string(ndb.Data), "a\n"; g != e {
		t.Fatalf("got %q\nexp %q", g, e)
	}
}

func TestNamedDataBlock2(t *testing.T) {
	const src = `$foo << EOF
ab
cde
EOF
print ""
`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	ndb := ast.StatementList.Statement.NamedDataBlock
	if g, e := string(ndb.Data), "ab\ncde\n"; g != e {
		t.Fatalf("got %q\nexp %q", g, e)
	}
}

func TestInlineData(t *testing.T) {
	const src = `plot '-'
a
e`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	data := ast.StatementList.Statement.Plot.Data
	if g, e := len(data), 1; g != e {
		t.Fatal(g, e)
	}

	if g, e := string(data[0]), "a\n"; g != e {
		t.Fatalf("got %q\nexp %q", g, e)
	}
}

func TestInlineData2(t *testing.T) {
	const src = `plot '-', '-'
ab
cde
e
fg
hij
e
print ""
`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	data := ast.StatementList.Statement.Plot.Data
	if g, e := len(data), 2; g != e {
		t.Fatal(g, e)
	}

	if g, e := string(data[0]), "ab\ncde\n"; g != e {
		t.Fatalf("got %q\nexp %q", g, e)
	}

	if g, e := string(data[1]), "fg\nhij\n"; g != e {
		t.Fatalf("got %q\nexp %q", g, e)
	}
}

func trim(s []byte) []byte {
	for {
		switch s[0] {
		case '\n', '\f':
			s = s[1:]
		default:
			return s
		}
	}
}

func Example_script() {
	const src = `
set term dumb
plot [-5:6.5] -sin(x/2) with impulse ls -1
`

	fmt.Printf("%s\n", src)
	out, err := Script([]byte(src))
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s\n", trim(out))
	// Output:
	// set term dumb
	// plot [-5:6.5] -sin(x/2) with impulse ls -1
	//
	//
	//
	//     1 ++----+-----------+-----------+-----------+-----------+-----------+-++
	//       |    +++||||||||+++           +           +         -sin(x/2) +---++ |
	//   0.8 ++ ++|||||||||||||+++                                               ++
	//       |++||||||||||||||||||++                                              |
	//   0.6 ++|||||||||||||||||||||+                                            ++
	//       ||||||||||||||||||||||||+                                            |
	//   0.4 ++|||||||||||||||||||||||++                                         ++
	//       |||||||||||||||||||||||||||+                                         |
	//   0.2 ++||||||||||||||||||||||||||++                                      ++
	//     0 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//       |                              +|||||||||||||||||||||||||||||||||||++|
	//  -0.2 ++                             ++|||||||||||||||||||||||||||||||||+ ++
	//       |                                +||||||||||||||||||||||||||||||++   |
	//  -0.4 ++                                ++|||||||||||||||||||||||||||+    ++
	//       |                                   +|||||||||||||||||||||||||+      |
	//  -0.6 ++                                   ++|||||||||||||||||||||++      ++
	//       |                                     +++|||||||||||||||||++         |
	//  -0.8 ++                                      +++|||||||||||||++          ++
	//       |     +           +           +           ++++|||||||+++          +  |
	//    -1 ++----+-----------+-----------+-----------+-----------+-----------+-++
	//            -4          -2           0           2           4           6
}

func Example_file() {
	const fname = "testdata/example.gp"

	src, err := ioutil.ReadFile(fname)
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s\n", src)
	out, err := File(fname)
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s\n", trim(out))
	// Output:
	// set term dumb
	// plot [-5:6.5] sin(x) with impulse ls -1
	//
	//
	//
	//     1 ++----+-----------+-----------+-----------+-----------+-----------+-++
	//       ||||+++           +           +     ++||||++          +sin(x) +---++ |
	//   0.8 ++||||+                             +|||||||                        ++
	//       |||||||+                          ++||||||||++                       |
	//   0.6 ++||||||+                        +||||||||||||                      ++
	//       |||||||||                        +||||||||||||+                      |
	//   0.4 ++|||||||+                      +||||||||||||||+                    ++
	//       ||||||||||+                    +||||||||||||||||                     |
	//   0.2 ++|||||||||                    +||||||||||||||||+                   ++
	//     0 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//       |          +||||||||||||||||||+                  |||||||||||||||||||+|
	//  -0.2 ++          +|||||||||||||||||                   +|||||||||||||||||+++
	//       |            +|||||||||||||||+                    +||||||||||||||||  |
	//  -0.4 ++           +||||||||||||||+                      +||||||||||||||+ ++
	//       |             +||||||||||||+                        +||||||||||||+   |
	//  -0.6 ++             +|||||||||||                         +|||||||||||+   ++
	//       |              ++||||||||++                          ++|||||||||     |
	//  -0.8 ++               +|||||||                             +|||||||++    ++
	//       |     +          ++||||++     +           +           +++||||+    +  |
	//    -1 ++----+-----------+-----------+-----------+-----------+-----------+-++
	//            -4          -2           0           2           4           6
}

func Example_parseString() {
	ast, err := ParseString("example.gp", "set term dumb")
	if err != nil {
		panic(err)
	}

	fmt.Println(ast)
	// Output:
	// &plot.AST{
	// · StatementList: &plot.StatementList{
	// · · Statement: &plot.Statement{
	// · · · Case: 22,
	// · · · Set: &plot.Set{
	// · · · · SetSpec: &plot.SetSpec{
	// · · · · · Case: 89,
	// · · · · · SetTerminalSpec: &plot.SetTerminalSpec{
	// · · · · · · SetTerminalInner: &plot.SetTerminalInner{
	// · · · · · · · Case: 10,
	// · · · · · · · Token: example.gp:1:10: IDENTIFIER "dumb",
	// · · · · · · },
	// · · · · · },
	// · · · · · Token: example.gp:1:5: IDENTIFIER "term",
	// · · · · },
	// · · · · Token: example.gp:1:1: IDENTIFIER "set",
	// · · · },
	// · · },
	// · },
	// }
}

func TestTmp(t *testing.T) {
	const src = `
rep x*y
`
	r := bytes.NewBufferString(src)
	ast, err := Parse("test", len(src), r)
	if err != nil {
		t.Fatal(errString(err))
	}

	t.Log(PrettyString(ast))
}
