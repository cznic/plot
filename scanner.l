%{
// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
%}

%yyc c
%yyn c = lx.Next()
%yym lx.Mark()

%{
package plot

func (lx *lexer) scan() int {
		c := lx.Enter()
%}

 /* Non ASCII character classes */
eof			\x80
other			\x81

any_to_eol		[^\x80\n\r]*
big_u_value		\\U{hex_digit}{hex_digit}{hex_digit}{hex_digit}{hex_digit}{hex_digit}{hex_digit}{hex_digit}
byte_value		{octal_byte_value}|{hex_byte_value}
decimal_digit		[0-9]
decimal_lit		[1-9]{decimal_digit}*
decimals		{decimal_digit}+
escaped_char		\\[abfnrtv'`\x22\\]
exponent		[eE][+-]?{decimals}*
float_lit		{decimals}"."{decimals}?{exponent}?|{decimals}{exponent}|"."{decimals}{exponent}?
hex_byte_value		\\x{hex_digit}?{hex_digit}?
hex_digit		[0-9a-fA-F]
hex_lit			0[xX]{hex_digit}+
ident			({ident_first}|"$"){ident_next}*
ident_first		[A-Za-z_]
ident_next		{ident_first}|[0-9]
int_lit			{decimal_lit}|{octal_lit}|{hex_lit}
interpreted_string_lit	\x22({str_unicode_value}|{byte_value})*\x22
little_u_value		\\u{hex_digit}{hex_digit}{hex_digit}{hex_digit}
nonzero-digit           [1-9]
number			{int_lit}|{float_lit}
octal-constant          0{octal-digit}*
octal-digit             [0-7]
octal_byte_value	\\{octal_digit}{octal_digit}?{octal_digit}?
octal_digit		[0-7]
octal_lit		0{octal_digit}*
raw_string_lit		'[^'\x80]*'
str_unicode_value	[^\x22\x80\n\r\\]|{little_u_value}|{big_u_value}|{escaped_char}
string_lit		{raw_string_lit}|{interpreted_string_lit}

%%
		c = lx.Rule0()

 /* Whitespace */
[ \t\r]+

 /* Line comment */
"#"{any_to_eol}

 /* Command substitution */
`[^`\x80]*`
		lx.substitute()

"!="		return	NOTEQ
"&&"		return	ANDAND
"**"		return	EXP
"<<"		return	LSH
"<="		return	LEQ
"=="		return	EQEQ
">="		return	GEQ
">>"		return	RSH
"||"		return	OROR

@{ident}	return	MACRO
{ident}		return	IDENTIFIER
{number}	return	NUM_LIT
{string_lit}	return	lx.expandStringLiteral()

%%
		if c, ok := lx.Abort(); ok {
			return c
		}

		goto yyAction
}
