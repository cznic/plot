// CAUTION: Generated file - DO NOT EDIT.

// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package plot

func (lx *lexer) scan() int {
	c := lx.Enter()

	/* Non ASCII character classes */

yystate0:
	yyrule := -1
	_ = yyrule
	c = lx.Rule0()
	/* Whitespace */

	goto yystart1

	goto yystate0 // silence unused label error
	goto yyAction // silence unused label error
yyAction:
	switch yyrule {
	case 1:
		goto yyrule1
	case 2:
		goto yyrule2
	case 3:
		goto yyrule3
	case 4:
		goto yyrule4
	case 5:
		goto yyrule5
	case 6:
		goto yyrule6
	case 7:
		goto yyrule7
	case 8:
		goto yyrule8
	case 9:
		goto yyrule9
	case 10:
		goto yyrule10
	case 11:
		goto yyrule11
	case 12:
		goto yyrule12
	case 13:
		goto yyrule13
	case 14:
		goto yyrule14
	case 15:
		goto yyrule15
	case 16:
		goto yyrule16
	}
	goto yystate1 // silence unused label error
yystate1:
	c = lx.Next()
yystart1:
	switch {
	default:
		goto yyabort
	case c == '!':
		goto yystate3
	case c == '"':
		goto yystate5
	case c == '#':
		goto yystate16
	case c == '$' || c >= 'A' && c <= 'Z' || c == '_' || c >= 'a' && c <= 'z':
		goto yystate17
	case c == '&':
		goto yystate18
	case c == '*':
		goto yystate21
	case c == '.':
		goto yystate23
	case c == '0':
		goto yystate27
	case c == '<':
		goto yystate33
	case c == '=':
		goto yystate36
	case c == '>':
		goto yystate38
	case c == '@':
		goto yystate41
	case c == '\'':
		goto yystate20
	case c == '\t' || c == '\r' || c == ' ':
		goto yystate2
	case c == '`':
		goto yystate43
	case c == '|':
		goto yystate45
	case c >= '1' && c <= '9':
		goto yystate32
	}

yystate2:
	c = lx.Next()
	yyrule = 1
	lx.Mark()
	switch {
	default:
		goto yyrule1
	case c == '\t' || c == '\r' || c == ' ':
		goto yystate2
	}

yystate3:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '=':
		goto yystate4
	}

yystate4:
	c = lx.Next()
	yyrule = 4
	lx.Mark()
	goto yyrule4

yystate5:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '"':
		goto yystate6
	case c == '\\':
		goto yystate7
	case c >= '\x01' && c <= '\t' || c == '\v' || c == '\f' || c >= '\x0e' && c <= '!' || c >= '#' && c <= '[' || c >= ']' && c <= '\u007f' || c >= '\u0081' && c <= 'ÿ':
		goto yystate5
	}

yystate6:
	c = lx.Next()
	yyrule = 16
	lx.Mark()
	goto yyrule16

yystate7:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '"' || c == '\'' || c >= '0' && c <= '7' || c == '\\' || c >= '`' && c <= 'b' || c == 'f' || c == 'n' || c == 'r' || c == 't' || c == 'v' || c == 'x':
		goto yystate5
	case c == 'U':
		goto yystate8
	case c == 'u':
		goto yystate12
	}

yystate8:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate9
	}

yystate9:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate10
	}

yystate10:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate11
	}

yystate11:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate12
	}

yystate12:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate13
	}

yystate13:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate14
	}

yystate14:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate15
	}

yystate15:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate5
	}

yystate16:
	c = lx.Next()
	yyrule = 2
	lx.Mark()
	switch {
	default:
		goto yyrule2
	case c >= '\x01' && c <= '\t' || c == '\v' || c == '\f' || c >= '\x0e' && c <= '\u007f' || c >= '\u0081' && c <= 'ÿ':
		goto yystate16
	}

yystate17:
	c = lx.Next()
	yyrule = 14
	lx.Mark()
	switch {
	default:
		goto yyrule14
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'Z' || c == '_' || c >= 'a' && c <= 'z':
		goto yystate17
	}

yystate18:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '&':
		goto yystate19
	}

yystate19:
	c = lx.Next()
	yyrule = 5
	lx.Mark()
	goto yyrule5

yystate20:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '\'':
		goto yystate6
	case c >= '\x01' && c <= '&' || c >= '(' && c <= '\u007f' || c >= '\u0081' && c <= 'ÿ':
		goto yystate20
	}

yystate21:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '*':
		goto yystate22
	}

yystate22:
	c = lx.Next()
	yyrule = 6
	lx.Mark()
	goto yyrule6

yystate23:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9':
		goto yystate24
	}

yystate24:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c == 'E' || c == 'e':
		goto yystate25
	case c >= '0' && c <= '9':
		goto yystate24
	}

yystate25:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c == '+' || c == '-' || c >= '0' && c <= '9':
		goto yystate26
	}

yystate26:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c >= '0' && c <= '9':
		goto yystate26
	}

yystate27:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c == '.':
		goto yystate24
	case c == '8' || c == '9':
		goto yystate29
	case c == 'E' || c == 'e':
		goto yystate25
	case c == 'X' || c == 'x':
		goto yystate30
	case c >= '0' && c <= '7':
		goto yystate28
	}

yystate28:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c == '.':
		goto yystate24
	case c == '8' || c == '9':
		goto yystate29
	case c == 'E' || c == 'e':
		goto yystate25
	case c >= '0' && c <= '7':
		goto yystate28
	}

yystate29:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '.':
		goto yystate24
	case c == 'E' || c == 'e':
		goto yystate25
	case c >= '0' && c <= '9':
		goto yystate29
	}

yystate30:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate31
	}

yystate31:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f':
		goto yystate31
	}

yystate32:
	c = lx.Next()
	yyrule = 15
	lx.Mark()
	switch {
	default:
		goto yyrule15
	case c == '.':
		goto yystate24
	case c == 'E' || c == 'e':
		goto yystate25
	case c >= '0' && c <= '9':
		goto yystate32
	}

yystate33:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '<':
		goto yystate34
	case c == '=':
		goto yystate35
	}

yystate34:
	c = lx.Next()
	yyrule = 7
	lx.Mark()
	goto yyrule7

yystate35:
	c = lx.Next()
	yyrule = 8
	lx.Mark()
	goto yyrule8

yystate36:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '=':
		goto yystate37
	}

yystate37:
	c = lx.Next()
	yyrule = 9
	lx.Mark()
	goto yyrule9

yystate38:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '=':
		goto yystate39
	case c == '>':
		goto yystate40
	}

yystate39:
	c = lx.Next()
	yyrule = 10
	lx.Mark()
	goto yyrule10

yystate40:
	c = lx.Next()
	yyrule = 11
	lx.Mark()
	goto yyrule11

yystate41:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '$' || c >= 'A' && c <= 'Z' || c == '_' || c >= 'a' && c <= 'z':
		goto yystate42
	}

yystate42:
	c = lx.Next()
	yyrule = 13
	lx.Mark()
	switch {
	default:
		goto yyrule13
	case c >= '0' && c <= '9' || c >= 'A' && c <= 'Z' || c == '_' || c >= 'a' && c <= 'z':
		goto yystate42
	}

yystate43:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '`':
		goto yystate44
	case c >= '\x01' && c <= '_' || c >= 'a' && c <= '\u007f' || c >= '\u0081' && c <= 'ÿ':
		goto yystate43
	}

yystate44:
	c = lx.Next()
	yyrule = 3
	lx.Mark()
	goto yyrule3

yystate45:
	c = lx.Next()
	switch {
	default:
		goto yyabort
	case c == '|':
		goto yystate46
	}

yystate46:
	c = lx.Next()
	yyrule = 12
	lx.Mark()
	goto yyrule12

yyrule1: // [ \t\r]+
	{

		/* Line comment */
		goto yystate0
	}
yyrule2: // "#"{any_to_eol}
	{

		/* Command substitution */
		goto yystate0
	}
yyrule3: // `[^`\x80]*`
	{

		lx.substitute()
		goto yystate0
	}
yyrule4: // "!="
	{
		return NOTEQ
	}
yyrule5: // "&&"
	{
		return ANDAND
	}
yyrule6: // "**"
	{
		return EXP
	}
yyrule7: // "<<"
	{
		return LSH
	}
yyrule8: // "<="
	{
		return LEQ
	}
yyrule9: // "=="
	{
		return EQEQ
	}
yyrule10: // ">="
	{
		return GEQ
	}
yyrule11: // ">>"
	{
		return RSH
	}
yyrule12: // "||"
	{
		return OROR
	}
yyrule13: // @{ident}
	{
		return MACRO
	}
yyrule14: // {ident}
	{
		return IDENTIFIER
	}
yyrule15: // {number}
	{
		return NUM_LIT
	}
yyrule16: // {string_lit}
	{
		return lx.expandStringLiteral()
	}
	panic("unreachable")

	goto yyabort // silence unused label error

yyabort: // no lexem recognized
	if c, ok := lx.Abort(); ok {
		return c
	}

	goto yyAction
}
