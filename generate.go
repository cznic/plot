// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build ignore

package main

import (
	"bytes"
	"flag"
	"fmt"
	"go/scanner"
	"go/token"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/cznic/parser/yacc"
)

var (
	tokenRE = regexp.MustCompile("^[a-zA-Z_][a-zA-Z0-9_-]*$")
)

func tokenName(lit string) string {
	b := []byte("T_")
	for i := 0; i < len(lit); i++ {
		switch c := lit[i]; {
		case c >= 'a' && c <= 'z' || c >= '0' && c <= '9':
			b = append(b, c)
		case c >= 'A' && c <= 'Z':
			b = append(b, '_', c)
		case c == '_':
			b = append(b, "__"...)
		case c == '-':
			b = append(b, "_d"...)
		default:
			panic("internal error")
		}
	}
	return strings.ToUpper(string(b))
}

func yy() (nm string, err error) {
	const (
		yyfn = "parser.yy"
		yfn  = "parser.y"
	)

	bsrc, err := ioutil.ReadFile(yyfn)
	if err != nil {
		return "", err
	}

	spec, err := parser.Parse(token.NewFileSet(), yyfn, bsrc)
	if err != nil {
		return "", err
	}

	m := map[string]bool{}
	for _, rule := range spec.Rules {
		for l := rule.RuleItemList; l != nil; l = l.RuleItemList {
			if l.Case == 3 { // RuleItemList STRING_LITERAL
				lit := l.Token.Val
				lit = lit[1 : len(lit)-1] // Unquote
				if tokenRE.MatchString(lit) {
					m[lit] = true
				}
			}
		}
	}

	a := []string{"%token"}
	for k := range m {
		a = append(a, k)
	}
	sort.Strings(a)
	for i, v := range a {
		if i == 0 {
			continue
		}

		a[i] = fmt.Sprintf("\t%s	%q", tokenName(v), v)
	}
	ins := strings.Join(a, "\n")
	src := string(bsrc)
	src = strings.Replace(src, "}\n\n%token", "}\n\n"+ins+"\n\n%token", 1)
	tmp, err := ioutil.TempFile("", "plot-generate")
	if err != nil {
		return "", err
	}

	if _, err := fmt.Fprintf(tmp, "%s\n", src); err != nil {
		return "", err
	}

	tmpNm := tmp.Name()
	if err := tmp.Close(); err != nil {
		return "", err
	}

	defer os.Remove(tmpNm)

	y, err := os.Create(yfn)
	if err != nil {
		return "", err
	}

	nm = y.Name()
	cmd := exec.Command(
		"yy",
		"-astImport", "\"go/token\"\n\n\"github.com/cznic/xc\"",
		"-kind", "Case",
		"-node", "Node",
		"-o", nm,
		"-prettyString", "PrettyString",
		tmpNm,
	)
	if out, err := cmd.CombinedOutput(); err != nil {
		os.Remove(nm)
		log.Printf("%s", out)
		log.Printf("(To install yy: $ go get github.com/cznic/yy)")
		return "", err
	}

	return nm, nil
}

func goyacc(y string) (err error) {
	t, err := ioutil.TempFile("", "go-generate-xegen-")
	if err != nil {
		log.Fatal(err)
	}

	defer func() {
		if e := os.Remove(t.Name()); e != nil && err == nil {
			err = e
		}
	}()

	cmd := exec.Command("goyacc", "-c", "-o", os.DevNull, "-xegen", t.Name(), y)
	if out, err := cmd.CombinedOutput(); err != nil {
		log.Printf("%s\n", out)
		log.Printf("(To install goyacc: $ go get github.com/cznic/yy)")
		return err
	}

	xerrors, err := ioutil.ReadFile("xerrors")
	if err != nil {
		return err
	}

	if _, err := t.Seek(0, 2); err != nil {
		return err
	}

	if _, err := t.Write(xerrors); err != nil {
		return err
	}

	cmd = exec.Command("goyacc", "-c", "-cr", "-xe", t.Name(), "-o", "parser.go", "-dlvalf", "%v", "-dlval", "PrettyString(lval.Token)", y)
	if out, err := cmd.CombinedOutput(); err != nil {
		log.Printf("%s", out)
		return err
	} else {
		log.Printf("%s", out)

	}

	return ed(
		"parser.go",
		// ------------------------------------------------------------
		"yyp := -1\n",
		"yyp := -1\n\tyychar0 := -1\n",

		"yychar = yylex1(yylex, &yylval)\n",
		`yychar = yylex1(yylex, &yylval)
		yychar0 = -1
		if yychar == IDENTIFIER {
			if x := shortcuts[yylval.Token.Val]; x != 0 {
				yychar0 = yychar
				yychar = x
				yylex.(*lexer).lookahead.Rune = rune(x)
				if yyDebug >= 3 {
					__yyfmt__.Printf("lex trying %s\n", yySymName(x))
				}
			}
		}
`,
		// ------------------------------------------------------------
		"yyn = 0\n",
		"retry:\n\tyyn = 0\n",
		// ------------------------------------------------------------
		"\tif yyn == 0 {\n",
		`
	if yyn == 0 && yychar0 == IDENTIFIER {
		yychar = IDENTIFIER
		yylex.(*lexer).lookahead.Rune = IDENTIFIER
		if yyDebug >= 3 {
			__yyfmt__.Printf("lex retry as IDENTIFIER\n")
		}
		yychar0 = -1
		var ok bool
		if yyxchar, ok = yyXLAT[yychar]; !ok {
			yyxchar = len(yySymNames) // > tab width
		}
		goto retry
	}

	if yyn == 0 {
`,
		// ------------------------------------------------------------
	)
}

func main() {
	if err := main0(); err != nil {
		scanner.PrintError(os.Stderr, err)
		os.Exit(1)
	}
}

func main0() (err error) {
	log.SetFlags(log.Lshortfile)
	p2 := flag.Bool("2", false, "")
	flag.Parse()
	if *p2 {
		return main2()
	}

	os.Remove("ast.go")
	os.Remove("ast_test.go")
	y, err := yy()
	if err != nil {
		return err
	}

	return goyacc(y)
}

func main2() (err error) {
	goCmd := exec.Command("go", "test", "-run", "^Example[^_]")
	out, err := goCmd.CombinedOutput() // Errors are expected and wanted here.
	feCmd := exec.Command("fe")
	feCmd.Stdin = bytes.NewBuffer(out)
	if out, err = feCmd.CombinedOutput(); err != nil {
		log.Printf("%s", out)
		log.Printf("(To install fe: $ go get github.com/cznic/fe)")
		return err
	}

	matches, err := filepath.Glob("*_test.go")
	if err != nil {
		return err
	}

	//TODO remove dependency on pcregrep.
	cmd := exec.Command("pcregrep", append([]string{"-nM", `\/\/ <nil>|// false|// -1|Output:\n}`}, matches...)...)
	if out, _ = cmd.CombinedOutput(); len(out) != 0 { // Error != nil when no matches
		log.Printf("%s", out)
		log.Printf("(To install pcregrep: use your distro package manager.)")
	}
	return nil
}

func ed(fn string, args ...string) error {
	if len(args)&1 != 0 {
		panic("internal error")
	}

	buf, err := ioutil.ReadFile(fn)
	if err != nil {
		return err
	}

	for i := 0; i < len(args); i += 2 {
		old := []byte(args[i])
		new := []byte(args[i+1])
		buf = bytes.Replace(buf, old, new, 1)
	}

	return ioutil.WriteFile(fn, buf, 0666)
}
