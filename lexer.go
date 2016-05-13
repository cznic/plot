// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package plot

import (
	"bytes"
	"fmt"
	"go/token"
	"io"
	"os/exec"
	"regexp"
	"strconv"
	"strings"

	"github.com/cznic/golex/lex"
	"github.com/cznic/xc"
)

const (
	ccEOF = iota + 0x80
	ccOther
)

var (
	argRE = regexp.MustCompile("^@ARG[1-9]$")
)

func runeClass(r rune) int {
	switch {
	case r == lex.RuneEOF:
		return ccEOF
	case r < 0x80:
		return int(r)
	default:
		return ccOther
	}
}

type lexer struct {
	*lex.Lexer             //
	ast        *AST        //
	closed     bool        //
	example    interface{} //
	file       string      //
	line       []xc.Token  //
	lineIndex  int         //
	lookahead  xc.Token    //
	nErrors    int         //
	opts       opts        //
	report     *xc.Report  //
	scope      *Bindings   //
	stringVal  int         //
}

func newLexer(nm string, sz int, r io.RuneReader) *lexer {
	report := xc.NewReport()
	report.ErrLimit = -1
	l, err := lex.New(
		xc.FileSet.AddFile(nm, -1, sz),
		r,
		lex.ErrorFunc(func(pos token.Pos, msg string) {
			report.Err(pos, msg)
		}),
		lex.RuneClass(runeClass),
		lex.BOMMode(lex.BOMIgnoreFirst),
	)
	if err != nil {
		report.Err(0, "%s", err)
	}
	return &lexer{
		Lexer:  l,
		file:   nm,
		report: report,
		scope:  newBindings(nil),
	}
}

func (lx *lexer) pushScope() *Bindings {
	s := newBindings(lx.scope)
	lx.scope = s
	return s
}

func (lx *lexer) popScope(n Node) *Bindings {
	s := lx.scope.Parent
	if s == nil {
		lx.err(n, "cannot pop scope")
		return nil
	}

	lx.scope = s
	return s
}

func (lx *lexer) err(n Node, format string, args ...interface{}) {
	lx.report.Err(n.Pos(), format, args...)
}

// Implements yyLexer.
func (lx *lexer) Error(msg string) {
	msg = strings.Replace(msg, "$end", "EOF", -1)
	t := lx.lookahead
	switch t.Rune {
	case IDENTIFIER, NUM_LIT:
		if strings.HasPrefix(msg, "unexpected ") {
			parts := strings.Split(msg, ", expected ")
			if len(parts) == 2 {
				msg = fmt.Sprintf("%s %s, expected %s", parts[0], t.S(), parts[1])
			}
		}
	}
	lx.err(t, "%s", msg)
	lx.nErrors++
	lx.closed = lx.nErrors > 10
}

// Implements yyLexerEx.
func (lx *lexer) Reduced(rule, state int, lval *yySymType) (stop bool) {
	if rule != lx.opts.exampleRule {
		return false
	}

	switch x := lval.Node.(type) {
	case interface {
		fragment() interface{}
	}:
		lx.example = x.fragment()
	default:
		lx.example = x
	}
	return true
}

func (lx *lexer) scanChar() lex.Char {
	var r rune
	if !lx.closed {
		r = rune(lx.scan())
		switch r {
		case lex.RuneEOF:
			r = 0
		}
	}
	return lex.NewChar(lx.First.Pos(), r)
}

func (lx *lexer) scanToken() xc.Token {
	c := lx.scanChar()
	val := xc.Dict.ID(lx.TokenBytes(nil))
	t := xc.Token{Char: c, Val: val}
	switch t.Rune {
	case STRING_LIT:
		t.Val = lx.stringVal
	}
	return t
}

// Implements yyLexer.
func (lx *lexer) Lex(lval *yySymType) int {
	var t xc.Token
	if lx.lineIndex >= len(lx.line) {
		lx.readLine()
		if f := lx.opts.readlineHook; f != nil {
			f(lx.line)
		}
	}
	t = lx.line[lx.lineIndex]
	lx.lineIndex++
	if t.Rune == IDENTIFIER {
		if i := lx.lineIndex; i < len(lx.line) {
			switch lx.line[i].Rune {
			case '=':
				switch t.Val {
				case idSkip:
					t.Rune = SKIPEQ
				case idDt:
					t.Rune = DTEQ
				}
			case '[':
				switch t.Val {
				case idSum:
					t.Rune = SUM
				}
			}
		}
	}
	lx.lookahead = t
	lval.Token = t
	return int(t.Rune)
}

func (lx *lexer) close(n Node, format string, args ...interface{}) {
	lx.err(n, format, args...)
	lx.closed = true
	lx.line = []xc.Token{{}}
	lx.lineIndex = 0
}

func (lx *lexer) substitute() {
	if lx.closed {
		return
	}

	if !lx.opts.enableCommandSubstitution {
		lx.err(lx.First, "command substitution not enabled")
		lx.closed = true
		return
	}

	cmd := lx.TokenBytes(nil)
	cmd = cmd[1 : len(cmd)-1]
	out, err := exec.Command("sh", "-c", string(cmd)).Output()
	if err != nil {
		lx.close(lx.First, "%v", err)
		return
	}

	pos := lx.First.Pos()
	var a []lex.Char
	b := bytes.NewBuffer(out)
	for {
		r, _, err := b.ReadRune()
		if err != nil {
			if err == io.EOF {
				break
			}

			lx.close(lx.First, "%v", err)
			return
		}

		a = append(a, lex.NewChar(pos, r))
	}
	for i, j := 0, len(a)-1; i < j; i, j = i+1, j-1 {
		a[i], a[j] = a[j], a[i]
	}
	lx.Unget(lx.Lookahead())
	lx.Unget(a...)
	lx.unget(lx.First, out)
}

func (lx *lexer) unget(n Node, s []byte) {
	pos := n.Pos()
	var a []lex.Char
	b := bytes.NewBuffer(s)
	for {
		r, _, err := b.ReadRune()
		if err != nil {
			if err == io.EOF {
				break
			}

			lx.close(n, "%v, err")
			return
		}

		a = append(a, lex.NewChar(pos, r))
	}
	for i, j := 0, len(a)-1; i < j; i, j = i+1, j-1 {
		a[i], a[j] = a[j], a[i]
	}
	lx.Unget(lx.Lookahead())
	lx.Unget(a...)
}

// s/\\\n//g
type preprocessor struct {
	io.RuneReader
	lx    *lex.Lexer
	state int
	r     rune
	sz    int
}

func newPreprocessor(r io.RuneReader) *preprocessor { return &preprocessor{RuneReader: r} }

func (x *preprocessor) ReadRune() (r rune, sz int, err error) {
	const (
		idle = iota
		backslash
		emit
	)

	for {
		switch x.state {
		case idle:
			if r, sz, err = x.RuneReader.ReadRune(); err != nil {
				return r, sz, err
			}

			switch r {
			case '\\':
				x.r, x.sz, x.state = r, sz, backslash
			default:
				return r, sz, nil
			}
		case backslash:
			if r, sz, err = x.RuneReader.ReadRune(); err != nil {
				return r, sz, err
			}

			switch r {
			case '\n':
				x.lx.File.AddLine(x.lx.Offset())
				x.state = idle
			default:
				x.r, x.sz, x.state, r, sz = r, sz, emit, x.r, x.sz
				return r, sz, nil
			}
		case emit:
			x.state = idle
			return x.r, x.sz, nil
		default:
			panic("internal error")
		}
	}
}

func (lx *lexer) expandStringLiteral() int {
	if lx.closed {
		return 0
	}

	lx.stringVal = 0
	s0 := lx.TokenBytes(nil)
	if s0[0] == '\'' {
		lx.stringVal = xc.Dict.ID(s0[1 : len(s0)-1])
		return STRING_LIT
	}

	s := preprocessString(string(s0))
	parts := strings.Split(s, "`")
	// p0 1st backtick p1 2nd backtick p2 3rd backtick p3 4th backtick ... p4
	if len(parts)&1 == 0 { // Must be odd.
		lx.close(lx.First, "invalid string literal (odd number of backticks)")
		return 0
	}

	for i := 1; i < len(parts); i += 2 {
		cmd := parts[i]
		out, err := exec.Command("sh", "-c", cmd).Output()
		if err != nil {
			lx.close(lx.First, "%v", err)
			return 0
		}

		parts[i] = string(out)
	}
	s = strings.Join(parts, "")
	s = strings.Replace(s, "\n", "\\n", -1)
	t, err := strconv.Unquote(postprocessString(s))
	if err != nil {
		lx.close(lx.First, "%v", err)
		return 0
	}

	lx.stringVal = xc.Dict.SID(t)
	return STRING_LIT
}

func (lx *lexer) readLine() {
	if lx.lineIndex < len(lx.line) {
		panic("internal error") // Line not consumed.
	}

	lx.line = lx.line[:0]
	lx.lineIndex = 0
	for {
		if lx.closed {
			lx.line = append(lx.line, xc.Token{})
			return
		}

		tok := lx.scanToken()
		switch tok.Rune {
		case 0, '\n':
			lx.line = append(lx.line, tok)
			return
		case MACRO:
			nm := tok.S()
			if argRE.Match(nm) {
				lx.unget(tok, []byte(`'""'`))
				break
			}

			nm = nm[1:] // Strip '@'.
			id := xc.Dict.ID(nm)
			switch n := lx.scope.Lookup(id); x := n.(type) {
			case nil:
				lx.close(tok, "undefined %s", nm)
				return

			case *VariableDefinition:
				e := x.Expression
				if e.Case != 24 { // UnaryExpression
					lx.close(e, "macro replacement expression must be a string constant")
					return
				}

				u := e.UnaryExpression
				if u.Case != 0 { // PrimaryExpression
					lx.close(u, "macro replacement expression must be a string constant")
					return
				}

				p := u.PrimaryExpression
				if p.Case != 0 { // Operand
					lx.close(p, "macro replacement expression must be a string constant")
					return
				}

				o := p.Operand
				if o.Case != 3 { // STRING_LIT
					lx.close(o, "macro replacement expression must be a string constant")
					return
				}

				s := xc.Dict.S(o.Token.Val)
				if bytes.IndexByte(s, '\n') >= 0 {
					lx.close(o.Token, "macro replacement string may not contain new line characters")
					return
				}

				lx.unget(o, xc.Dict.S(o.Token.Val))
			default:
				lx.close(tok, "undefined %s", nm)
				return
			}

		default:
			lx.line = append(lx.line, tok)
		}
	}
}

func (lx *lexer) getInlineFiles(n int, eod []byte) [][]byte {
	var r [][]byte
	for i := 0; i < n; i++ {
		data := []byte(nil)
		for {
			c := lx.Next()
			if c == '\n' || c == ccEOF {
				b := lx.TokenBytes(nil)[1:]
				done := bytes.Equal(b, eod)
				lx.Rule0()
				if done {
					r = append(r, data)
					break
				}

				data = append(data, b...)
				data = append(data, '\n')
			}
		}
	}
	return r
}
