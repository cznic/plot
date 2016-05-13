// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package plot

import (
	"go/token"
	"reflect"
	"regexp"
	"strconv"
	"strings"

	"github.com/cznic/golex/lex"
	"github.com/cznic/strutil"
	"github.com/cznic/xc"
)

const (
	unicodePrivate = 0xe000
)

var (
	printHooks = strutil.PrettyPrintHooks{}
	shortcuts  = map[int]int{}

	idDash = xc.Dict.SID("-")
	idDt   = xc.Dict.SID("dt")
	idSkip = xc.Dict.SID("skip")
	idSum  = xc.Dict.SID("sum")

	tokenRE = regexp.MustCompile("^[a-zA-Z_][a-zA-Z0-9_-]*$")
)

func init() {
	for k, v := range xc.PrintHooks {
		printHooks[k] = v
	}
	lcRT := reflect.TypeOf(lex.Char{})
	lcH := func(f strutil.Formatter, v interface{}, prefix, suffix string) {
		c := v.(lex.Char)
		r := c.Rune
		s := yySymName(int(r))
		if x := s[0]; x >= '0' && x <= '9' {
			s = strconv.QuoteRune(r)
		}
		f.Format("%s%v: %s"+suffix, prefix, position(c.Pos()), s)
	}

	printHooks[lcRT] = lcH
	printHooks[reflect.TypeOf(xc.Token{})] = func(f strutil.Formatter, v interface{}, prefix, suffix string) {
		t := v.(xc.Token)
		if !t.Pos().IsValid() {
			return
		}

		lcH(f, t.Char, prefix, "")
		if s := xc.Dict.S(t.Val); len(s) != 0 {
			f.Format(" %q", s)
		}
		f.Format(suffix)
		return
	}
}

func init() {
	yyYLAT := map[int]int{}
	for k, v := range yyXLAT {
		yyYLAT[v] = k
	}
	syms := map[string]int{}
	for i, nm := range yySymNames {
		if nm == "" {
			continue
		}

		if !strings.HasPrefix(nm, "T_") {
			continue
		}

		syms[nm] = yyYLAT[i]
	}

	m := map[string][]int{}
	for _, nm := range yyTokenLiteralStrings {
		if !tokenRE.MatchString(nm) {
			continue
		}

		u := tokenName(nm)
		val, ok := syms[u]
		if !ok {
			continue
		}

		for nm != "" {
			m[nm] = append(m[nm], val)
			nm = nm[:len(nm)-1]
		}
	}

	for _, nm := range yyTokenLiteralStrings {
		if !tokenRE.MatchString(nm) {
			continue
		}

		u := tokenName(nm)
		val, ok := syms[u]
		if !ok {
			continue
		}

		m[nm] = []int{val}
	}

	for nm, val := range m {
		if len(val) == 1 {
			shortcuts[xc.Dict.SID(nm)] = val[0]
		}
	}
}

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

// PrettyString returns pretty formatted strings of things produced by this package.
func PrettyString(v interface{}) string { return strutil.PrettyString(v, "", "", printHooks) }

func position(pos token.Pos) token.Position { return xc.FileSet.Position(pos) }

// Bindings map name IDs to declaration nodes.
type Bindings struct {
	Map    map[int]Node
	Parent *Bindings
}

func newBindings(parent *Bindings) *Bindings {
	return &Bindings{
		Map:    map[int]Node{},
		Parent: parent,
	}
}

func (b *Bindings) declare(nm xc.Token, node Node) {
	b.Map[nm.Val] = node
}

func (b *Bindings) Lookup(nm int) Node {
	for b != nil {
		if n := b.Map[nm]; n != nil {
			return n
		}

		b = b.Parent
	}
	return nil
}

func preprocessString(s string) string {
	runes := []rune(s)
	w := 0
	for r := 0; r < len(runes); {
		c := runes[r]
		r++
		switch c {
		case '\\':
			if r == len(runes) {
				break
			}

			c := runes[r]
			r++
			switch c {
			case '\'':
				runes[w] = c
				w++
			case '`':
				runes[w] = unicodePrivate
				w++
			default:
				runes[w] = '\\'
				w++
				runes[w] = c
				w++
			}
		default:
			runes[w] = c
			w++
		}
	}
	return string(runes[:w])
}

func postprocessString(s string) string { return strings.Replace(s, string(unicodePrivate), "`", -1) }
