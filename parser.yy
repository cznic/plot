%{
// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package plot

import (
	"github.com/cznic/xc"
)
%}

%union {
        	Node    Node
        	Token   xc.Token
}

%token

		/*yy:token "ident_%c"	*/	IDENTIFIER	"identifier"
		/*yy:token "%d"		*/	NUM_LIT		"number literal"
		/*yy:token "'%c'"	*/	STRING_LIT	"string literal"

		MACRO

		ANDAND	"&&"
		EQEQ	"=="
		EXP	"**"
		GEQ	">="
		LEQ	"<="
		LSH	"<<"
		NOTEQ	"!="
		OROR	"||"
		RSH	">>"

		SKIPEQ	"skip "
		DTEQ	"dt "
		SUM	"sum "

%type		<Node>
		AST	"Gnuplot script"

%precedence	LESS_EXPR
%precedence
		'{'
		IDENTIFIER
		NUM_LIT
		STRING_LIT

%right		'='
%right		':' '?'
%left		OROR
%left		ANDAND
%left		'|'
%left		'^'
%left		'&'
%left		EQEQ NOTEQ T_EQ T_NE
%left		'<' '>' GEQ LEQ
%left		LSH RSH
%precedence	LESS_ADD_SUB
%left		'+' '-' '.'
%left		'%' '*' '/' EXP

%precedence	LESS_FACTORIAL
%left		'!' '~' SUM

%precedence	LESS_LBRACKET
%right		'['

%precedence	LESS_SKIP
%precedence	T_SKIP

%precedence	LESS_LPAREN
%precedence	'('

%precedence	LESS_COMMA
%precedence	','

%precedence	LESS_STYLE
%precedence
		T_BORDER
		T_DASHTYPE
		T_DT
		T_EMPTY
		T_FILL
		T_FS
		T_LINECOLOR
		T_LINESTYLE
		T_LINETYPE
		T_LINEWIDTH
		T_LS

%precedence	LESS_LT
%precedence
		T_LT
		T_LW
		T_NOBORDER
		T_NOCONTOURS
		T_NOHIDDEN3D
		T_NOSURFACE
		T_NOTITLE
		T_PALETTE
		T_PI
		T_POINT
		T_POINTINTERVAL
		T_POINTSIZE
		T_POINTTYPE
		T_PS
		T_PT
		T_TC
		T_TITLE

%precedence	LESS_LC
%precedence	T_LC

%precedence	LESS_T_Z
%precedence	T_Z

%start		AST

%%

AST:
   	StatementList
	{
		lx.ast = lhs
	}

AngleUnit:
	"deg"
|	"d"
|	"pi"

ArrowStyleList:
	ArrowStyleListItem
|	ArrowStyleList ArrowStyleListItem

/*
set style arrow <index> 
	{nohead | head | heads}
	{size <length>,<angle>{,<backangle>} {fixed}}
	{filled | empty | nofilled | noborder}
	{front | back}
	{ 
		{linestyle | ls <line_style>}
		| {linetype | lt <line_type>}
		{linewidth | lw <line_width}
		{linecolor | lc <colorspec>}
		{dashtype | dt <dashtype>} 
	}
*/
ArrowStyleListItem:
	"head"
|	"nohead"
|	"heads"
|	"size" Position
|	"size" Position "fixed"
|	"filled"
|	"empty"
|	"nofilled"
|	"noborder"
|	"front"
|	LineStyleListItem

BinaryList:
	BinaryListItem
|	BinaryList BinaryListItem

BinaryListItem:
	"array" '=' '(' ExpressionList ')'
|	"array" '=' ColonExpressionList
|	"center" '=' '(' ExpressionList ')'
|	"dx" '=' Expression
|	"dy" '=' Expression
|	"dz" '=' Expression
|	"endian" '=' Endianess
|	"filetype" '=' "auto"
|	"filetype" '=' "avs"
|	"filetype" '=' "edf"
|	"filetype" '=' "png"
|	"flip" '=' "x"
|	"flip" '=' "y"
|	"flip" '=' "z"
|	"flipx"
|	"flipy"
|	"flipz"
|	"format" '=' Expression
|	"general"
|	"origin" '=' OriginList
|	"perpendicular" '=' '(' ExpressionList ')'
|	"record" '=' '(' ExpressionList ')'
|	"record" '=' ColonExpressionList
|	"rot" '=' Expression
|	"rot" '=' Expression AngleUnit
|	"rotate" '=' Expression
|	"rotate" '=' Expression AngleUnit
|	"rotation" '=' Expression
|	"rotation" '=' Expression AngleUnit
|	"scan" '=' "xy"
|	"scan" '=' "xyz"
|	"scan" '=' "xzy"
|	"scan" '=' "yx"
|	"scan" '=' "yxz"
|	"scan" '=' "yzx"
|	"scan" '=' "zxy"
|	"scan" '=' "zyx"
|	"transpose"
//yy:example "plot ident_a binary skip = ident_b"
|	SKIPEQ '=' ColonExpressionList
//yy:example "plot ident_a binary dt = ident_b"
|	DTEQ '=' Expression

BinaryListOpt:
	/* empty */ {}
|	BinaryList

/*
bind {allwindows} [<key-sequence>] ["<gnuplot commands>"]
bind <key-sequence> ""
*/
Bind:
	"bind" Expression SimpleExpression
|	"bind" "a" Expression SimpleExpression
|	"bind" "all" Expression SimpleExpression
|	"bind" "allwindows" Expression SimpleExpression

Call:
	"call" SimpleExpressionList

Cd:
	"cd"	Expression

Clear:
     	"clear"

ColonExpressionList:
	NonParenthesizedExpression
|	ColonExpressionList ':' NonParenthesizedExpression

ColonExpressionOptList:
	/* empty */ %prec LESS_EXPR {}
|	NonParenthesizedExpression
|	ColonExpressionOptList ':'
|	ColonExpressionOptList ':' NonParenthesizedExpression

ColorSpec:
	"bgnd"
|	"black"
|	"pal" %prec LESS_T_Z
|	"pal" "cbrange" Expression %prec LESS_EXPR
|	"pal" "frac" Expression %prec LESS_EXPR
|	"pal" "z"
|	"palette" %prec LESS_T_Z
|	"palette" "cbrange" Expression %prec LESS_EXPR
|	"palette" "frac" Expression %prec LESS_EXPR
|	"palette" "z"
|	"rgb" "var"
|	"rgb" "variable"
|	"rgb" Expression %prec LESS_EXPR
|	"rgbcolor" "var"
|	"rgbcolor" "variable"
|	"rgbcolor" Expression %prec LESS_EXPR
|	"variable"
|	Expression %prec LESS_EXPR
 
ComplexNumber:
	'{' Expression ',' Expression '}'

CoordinateSystemOpt:
	/* empty */ {}
|	"first"
|	"second"
|	"graph"
|	"screen"
|	"char"
|	"character"

DashTypeSpec:
	"solid"
|	Expression

/*
Syntax:
plot ’<file_name>’ 
	{binary <binary list>}
	{{nonuniform} matrix}
	{index <index list> | index "<name>"}
	{every <every list>}
	{skip <number-of-lines>}
	{using <using list>}
	{smooth <option>}
	{volatile} {noautoscale}
*/
DatafileModifiersList:
	DatafileModifiersListItem
|	DatafileModifiersList DatafileModifiersListItem

DatafileModifiersListItem:
	"binary" BinaryListOpt
|	"matrix"
|	"nonuniform" "matrix"
|	"in" ColonExpressionList
|	"index" ColonExpressionList
|	"every" ColonExpressionOptList
|	"skip" Expression
|	"u" UsingList
|	"u" UsingList SimpleExpression
|	"using" UsingList
|	"using" UsingList SimpleExpression
|	"sm" Smoothing
|	"smooth" Smoothing
|	"volatile"
|	"noautoscale"
|	"columnheaders"
|	"rowheaders"

DatafileModifiersListOpt:
	/* empty */ {}
|	DatafileModifiersList

Do:
	"do" IterationSpecifier '{'
	{
		lx.pushScope()
	}
	StatementList '}'
	{
		lx.popScope(lhs.Token3)
	}

// Old style.
Else:
	"else" Statement

EndConditionList:
	EndConditionListItem
|	EndConditionList ',' EndConditionListItem

EndConditionListItem:
	"any"
|	"button1"
|	"button2"
|	"button3"
|	"close"
|	"keypress"
|	"key"

Endianess:
	"big"
|	"default"
|	"little"
|	"middle"
|	"swap"

Eval:
	"eval" Expression

Exit:
	"exit"
|	"exit" "error" Expression
|	"exit" "gnuplot"

Expression:
	Expression "!=" Expression
|	Expression "&&" Expression
|	Expression "**" Expression
|	Expression "<<" Expression
|	Expression "<=" Expression
|	Expression "==" Expression
|	Expression ">=" Expression
|	Expression ">>" Expression
|	Expression "eq" Expression
|	Expression "ne" Expression
|	Expression "||" Expression
|	Expression '%' Expression
|	Expression '&' Expression
|	Expression '*' Expression
|	Expression '+' Expression
|	Expression '-' Expression
|	Expression '.' Expression
|	Expression '/' Expression
|	Expression '<' Expression
|	Expression '=' Expression
|	Expression '>' Expression
|	Expression '?' Expression ':' Expression
|	Expression '^' Expression
|	Expression '|' Expression
|	UnaryExpression %prec LESS_FACTORIAL

ExpressionList:
	Expression
|	ExpressionList ',' Expression

ExpressionUnitList:
	Expression
|	Expression Unit
|	ExpressionUnitList ',' Expression
|	ExpressionUnitList ',' Expression Unit

ExpressionOpt:
	/* empty */ %prec LESS_EXPR {}
|	Expression

ExpressionOptList:
	/* empty */ {}
|	Expression
|	ExpressionOptList ','
|	ExpressionOptList ',' Expression

Fit:
	"fit" RangesOpt Expression SimpleExpression DatafileModifiersListOpt FitOptionsListOpt "via" ExpressionList

FitOptionsList:
	FitOptionsListItem
|	FitOptionsList FitOptionsListItem

FitOptionsListItem:
	"unitweights"
|	"xerror"
|	"xyerror"
|	"yerror"
|	"errors" IdentifierList

FitOptionsListOpt:
	/* empty */
|	FitOptionsList

FunctionDefinition:
	IDENTIFIER '(' IdentifierList ')' '=' Expression

IdentifierList:
	IDENTIFIER
|	IdentifierList ',' IDENTIFIER

IdentifierOptList:
	/* empty*/
|	IDENTIFIER	
|	IdentifierOptList ','
|	IdentifierOptList ',' IDENTIFIER

If:
	IfHeader
|	IfHeader "else" '{'
	{
		lx.pushScope()
	}
	StatementList '}'
	{
		lx.popScope(lhs.Token3)
	}
|	"if" '(' Expression ')' Statement // Old style.

IfHeader:
	"if" '(' Expression ')' '{'
	{
		lx.pushScope()
	}
	StatementList '}'
	{
		lx.popScope(lhs.Token5)
	}

Import:
	"import" IDENTIFIER '(' IdentifierList ')' "from" Expression

IterationSpecifier:
	"for" '[' Expression ':' Expression ':' Expression ']'
|	"for" '[' Expression ':' Expression ']'
|	"for" '[' Expression ':' '*' ']'
|	"for" '[' Expression "in" Expression ']'

IterationSpecifierOpt:
	/* empty */ {}
|	IterationSpecifier

LineStyleList:
	LineStyleListItem
|	LineStyleList LineStyleListItem

/*
with <style> 
	{ 
		{linestyle | ls <line_style>}
		| 
		{
			{linetype | lt <line_type>}
			{linewidth | lw <line_width>}
			{linecolor | lc <colorspec>}
			{pointtype | pt <point_type>}
			{pointsize | ps <point_size>}
			{fill | fs <fillstyle>}
			{nohidden3d} {nocontours} {nosurface}
			{palette}
		}
	}
*/
LineStyleListItem:
	"linestyle" Expression
|	"ls" Expression
|	"linetype" ColorSpec
|	"lt" ColorSpec
|	"linewidth" Expression
|	"lw" Expression
|	"linecolor" ColorSpec
|	"lc" ColorSpec
|	"pointtype" Expression
|	"pt" Expression
|	"pointsize" Expression
|	"ps" Expression
|	"fill" SetStyleFillSpecList %prec LESS_STYLE
|	"fs" SetStyleFillSpecList %prec LESS_STYLE
|	"nohidden3d"
|	"nocontours"
|	"nosurface"
|	"palette"
|	"dashtype" DashTypeSpec
|	"dt" DashTypeSpec
|	"pi" Expression
|	"pointinterval" Expression
|	"tc" ColorSpec

Load:
	"load"	Expression

Lower:
	"lower"
|	"lower"	PlotWindow

//yy:field	Data	[]byte	// The content of the named data block.
//yy:example "$data << EOD\n1 2 3\nEOD\n"
NamedDataBlock:
	IDENTIFIER "<<" IDENTIFIER
	{
		lhs.post(lx)
	}


NonParenthesizedExpression:
	NonParenthesizedExpression "!=" NonParenthesizedExpression
|	NonParenthesizedExpression "&&" NonParenthesizedExpression
|	NonParenthesizedExpression "**" NonParenthesizedExpression
|	NonParenthesizedExpression "<<" NonParenthesizedExpression
|	NonParenthesizedExpression "<=" NonParenthesizedExpression
|	NonParenthesizedExpression "==" NonParenthesizedExpression
|	NonParenthesizedExpression ">=" NonParenthesizedExpression
|	NonParenthesizedExpression ">>" NonParenthesizedExpression
|	NonParenthesizedExpression "eq" NonParenthesizedExpression
|	NonParenthesizedExpression "ne" NonParenthesizedExpression
|	NonParenthesizedExpression "||" NonParenthesizedExpression
|	NonParenthesizedExpression '%' NonParenthesizedExpression
|	NonParenthesizedExpression '&' NonParenthesizedExpression
|	NonParenthesizedExpression '*' NonParenthesizedExpression
|	NonParenthesizedExpression '+' NonParenthesizedExpression
|	NonParenthesizedExpression '-' NonParenthesizedExpression
|	NonParenthesizedExpression '.' NonParenthesizedExpression
|	NonParenthesizedExpression '/' NonParenthesizedExpression
|	NonParenthesizedExpression '<' NonParenthesizedExpression
|	NonParenthesizedExpression '=' NonParenthesizedExpression
|	NonParenthesizedExpression '>' NonParenthesizedExpression
|	NonParenthesizedExpression '?' NonParenthesizedExpression ':' NonParenthesizedExpression
|	NonParenthesizedExpression '^' NonParenthesizedExpression
|	NonParenthesizedExpression '|' NonParenthesizedExpression
|	UnaryNonParenthesizedExpression %prec LESS_FACTORIAL

NonParenthesizedOperand:
	IDENTIFIER
|	NUM_LIT
|	STRING_LIT
|	ComplexNumber
|	SUM '[' Expression ':' Expression ']' Expression %prec SUM

//yy:example "set tics ( ident_a != ident_b )"		
NonStringExpression:		
	NonStringExpression "!=" NonStringExpression		
//yy:example "set tics ( ident_a && ident_b )"		
|	NonStringExpression "&&" NonStringExpression		
//yy:example "set tics ( ident_a ** ident_b )"		
|	NonStringExpression "**" NonStringExpression		
//yy:example "set tics ( ident_a << ident_b )"		
|	NonStringExpression "<<" NonStringExpression		
//yy:example "set tics ( ident_a <= ident_b )"		
|	NonStringExpression "<=" NonStringExpression		
//yy:example "set tics ( ident_a == ident_b )"		
|	NonStringExpression "==" NonStringExpression		
//yy:example "set tics ( ident_a >= ident_b )"		
|	NonStringExpression ">=" NonStringExpression		
//yy:example "set tics ( ident_a >> ident_b )"		
|	NonStringExpression ">>" NonStringExpression		
//yy:example "set tics ( ident_a eq ident_b )"		
|	NonStringExpression "eq" NonStringExpression		
//yy:example "set tics ( ident_a ne ident_b )"		
|	NonStringExpression "ne" NonStringExpression		
//yy:example "set tics ( ident_a || ident_b )"		
|	NonStringExpression "||" NonStringExpression		
//yy:example "set tics ( ident_a % ident_b )"		
|	NonStringExpression '%' NonStringExpression		
//yy:example "set tics ( ident_a & ident_b )"		
|	NonStringExpression '&' NonStringExpression		
//yy:example "set tics ( ident_a * ident_b )"		
|	NonStringExpression '*' NonStringExpression		
//yy:example "set tics ( ident_a + ident_b )"		
|	NonStringExpression '+' NonStringExpression		
//yy:example "set tics ( ident_a - ident_b )"		
|	NonStringExpression '-' NonStringExpression		
//yy:example "set tics ( ident_a . ident_b )"		
|	NonStringExpression '.' NonStringExpression		
//yy:example "set tics ( ident_a / ident_b )"		
|	NonStringExpression '/' NonStringExpression		
//yy:example "set tics ( ident_a < ident_b )"		
|	NonStringExpression '<' NonStringExpression		
//yy:example "set tics ( ident_a = ident_b )"		
|	NonStringExpression '=' NonStringExpression		
//yy:example "set tics ( ident_a > ident_b )"		
|	NonStringExpression '>' NonStringExpression		
//yy:example "set tics ( ident_a ? ident_b : ident_c )"		
|	NonStringExpression '?' NonStringExpression ':' NonStringExpression		
//yy:example "set tics ( ident_a ^ ident_b )"		
|	NonStringExpression '^' NonStringExpression		
//yy:example "set tics ( ident_a | ident_b )"		
|	NonStringExpression '|' NonStringExpression		
|	UnaryNonStringExpression %prec LESS_FACTORIAL		

NonStringOperand:		
	'(' Expression ')'		
|	IDENTIFIER %prec LESS_LPAREN		
|	NUM_LIT		
|	ComplexNumber		

//yy:field	scope	*Bindings
Operand:
	'(' ExpressionList ')'
|	IDENTIFIER %prec LESS_LPAREN
	{
		lhs.scope = lx.scope
	}
|	NUM_LIT
|	STRING_LIT
|	ComplexNumber
|	SUM '[' Expression ':' Expression ']' Expression %prec SUM

OriginList:
	'(' ExpressionList ')'
|	OriginList ':' '(' ExpressionList ')'
 
Pause:
	"pause" "mouse" EndConditionList
|	"pause" "mouse" EndConditionList Expression
|	"pause" "mouse" Expression
|	"pause" Expression
|	"pause" Expression SimpleExpression

/*
plot {<ranges>} <plot-element> {, <plot-element>, <plot-element>}
plot-element:
	{<iteration>}
	<definition> | {sampling-range} <function> | <data source>
	{axes <axes>} {<title-spec>}
	{with <style>}

Note:	'ranges' and 'sampling-range' are collapsed into the Ranges production.
*/
//yy:field	Data	[][]byte	// Content of the inline data block(s).
Plot:
	"plot" PlotElementList
	{
		lhs.post(lx)
	}

PlotElementAxes:
	"axes" "x1y1"
|	"axes" "x1y2"
|	"axes" "x2y1"
|	"axes" "x2y2"

PlotElementList:
	PlotElementListItem
|	PlotElementList ',' PlotElementListItem

PlotElementListItem:
	"newhistogram" PlotNewhistogramSpecListOpt
|	IterationSpecifierOpt RangesOpt Expression PlotElementModifiersListOpt
|	IterationSpecifierOpt RangesOpt "sample" Ranges Expression PlotElementModifiersListOpt

//yy:field	isBinary bool
PlotElementModifiersList:
	PlotElementModifiersListItem
|	PlotElementModifiersList PlotElementModifiersListItem

//yy:field	isBinary bool
PlotElementModifiersListItem:
	PlotElementAxes
|	PlotElementTitle
|	"w" PlotElementStyle
|	"with" PlotElementStyle
|	LineStyleListItem
|	"whiskerbars"
|	DatafileModifiersListItem
	{
		lhs.isBinary = lhs.DatafileModifiersListItem.Case == 0 // "binary" BinaryListOpt
	}

PlotElementModifiersListOpt:
	/* empty */ {}
|	PlotElementModifiersList

PlotElementStyle:
	"boxerrorbars"
|	"boxes"
|	"boxplot"
|	"boxxyerrorbars"
|	"candlesticks"
|	"circles"
|	"dots"
|	"ellipses" UnitsOpt
|	"e"
|	"errorbars"
|	"errorlines"
|	"filledcurves" PlotElementStyleFilledcurvesSpecListOpt
|	"financebars"
|	"fsteps"
|	"histeps"
|	"his" PlotElementStyleHistogramsListOpt
|	"histogram" PlotElementStyleHistogramsListOpt
|	"histograms" PlotElementStyleHistogramsListOpt
|	"image"
|	"image" "pixels"
|	"impulses"
|	"labels" %prec LESS_STYLE
|	"labels" PlotElementStyleLabelsSpecList %prec LESS_STYLE
|	"l"
|	"line"
|	"lines"
|	"lp"
|	"linespoints"
|	"parallel"
|	"parallelaxes"
|	"pm3d"
|	"points"
|	"rgbalpha"
|	"rgbimage"
|	"steps"
|	"surface"
|	"vectors" PlotElementStyleVectorsSpecOpt
|	"xerr"
|	"xerrorbar"
|	"xerrorlines"
|	"xyerr"
|	"xyerrorbars"
|	"xyerrorlines"
|	"yerr"
|	"yerrorbars"
|	"yerrorlines"

PlotElementStyleLabelsSpecList:
	PlotElementStyleLabelsSpecListItem
|	PlotElementStyleLabelsSpecList PlotElementStyleLabelsSpecListItem

PlotElementStyleLabelsSpecListItem:
	"at" Position
|	"left"
|	"center"
|	"right"
|	"norotate"
|	"rotate"
|	"rotate" "by" Expression
|	"font" Expression
|	"noenhanced"
|	"front"
|	"back"
|	"textcolor" ColorSpec
|	"point"
|	"nopoint"
|	"offset" Expression %prec LESS_COMMA
|	"offset" Expression ',' Expression
|	"boxed"
|	"hypertext"
|	LineStyleListItem
|	"notitle" ExpressionOpt

PlotElementStyleFilledcurvesSpecList:
	PlotElementStyleFilledcurvesSpecListItem
|	PlotElementStyleFilledcurvesSpecList PlotElementStyleFilledcurvesSpecListItem

PlotElementStyleFilledcurvesSpecListItem:
	"closed"
|	"above"
|	"below"
|	"x1"
|	"x2"
|	"y"
|	"y1"
|	"y2"
|	"r"
|	"x1" '=' Expression
|	"x2" '=' Expression
|	"y" '=' Expression
|	"y1" '=' Expression
|	"y2" '=' Expression
|	"r" '=' Expression
|	"xy" '=' Expression ',' Expression

PlotElementStyleFilledcurvesSpecListOpt:
	/* empty */ {}
|	PlotElementStyleFilledcurvesSpecList

/*
set style histogram clustered {gap <gapsize>}
set style histogram errorbars {gap <gapsize>} {<linewidth>}
set style histogram rowstacked
set style histogram columnstacked
set style histogram {title font "name,size" tc <colorspec>}
*/
PlotElementStyleHistogramsList:
	PlotElementStyleHistogramsListItem
|	PlotElementStyleHistogramsList PlotElementStyleHistogramsListItem

PlotElementStyleHistogramsListItem:
	"cluster"
|	"clustered"
|	"gap" Expression
|	"gap" Expression SimpleExpression
|	"errorbars"
|	"rows"
|	"rowstacked"
|	"columns"
|	"columnstacked"
|	"title"
|	"font" Expression
|	"tc" ColorSpec
|	"textcolor" ColorSpec
|	"offset" Position
|	"boxed"

PlotElementStyleHistogramsListOpt:
	/* empty */ %prec LESS_STYLE {}
|	PlotElementStyleHistogramsList %prec LESS_STYLE

PlotElementStyleVectorsSpecOpt:
	/* empty */ %prec LESS_STYLE
|	"arrowstyle" "variable"
|	"arrowstyle" Expression
|	"as" "variable"
|	"as" Expression
|	ArrowStyleList %prec LESS_STYLE

/*
title <text> | notitle [<ignored text>]
title columnheader | title columnheader(N)
	{at {beginning|end}}
*/
PlotElementTitle:
	"notitle" ExpressionOpt
|	"columnheader" PlotElementTitlePosOpt
|	"t" PlotElementTitleSpec
|	"ti" PlotElementTitleSpec
|	"title" PlotElementTitleSpec

PlotElementTitleSpec:
	Expression PlotElementTitlePosOpt
|	"column" '(' Expression ')' PlotElementTitlePosOpt
|	"columnheader" '(' Expression ')' PlotElementTitlePosOpt

PlotElementTitlePosOpt:
	/* empty */ {}
|	"at" "beginning"
|	"at" "end"

/*
newhistogram {"<title>" {font "name,size"} {tc <colorspec>}}
	{lt <linetype>} {fs <fillstyle>} {at <x-coord>}
*/
PlotNewhistogramSpecList:
	PlotNewhistogramSpecListItem
|	PlotNewhistogramSpecList PlotNewhistogramSpecListItem

PlotNewhistogramSpecListItem:
	SimpleExpression
|	"font" Expression
|	"tc" ColorSpec
|	"textcolor" ColorSpec
|	"lt" ColorSpec
|	"linetype" ColorSpec
|	"fs" SetStyleFillSpecList %prec LESS_LT
|	"fillstyle" SetStyleFillSpecList %prec LESS_LT
|	"at" Position

PlotNewhistogramSpecListOpt:
	/*empty*/
|	PlotNewhistogramSpecList

PlotWindow:
	"pm"
|	"win"
|	"wxt"
|	"x11"

Position:
	CoordinateSystemOpt Expression %prec LESS_COMMA
|	CoordinateSystemOpt Expression ',' CoordinateSystemOpt Expression %prec LESS_COMMA
|	CoordinateSystemOpt Expression ',' CoordinateSystemOpt Expression ',' CoordinateSystemOpt Expression %prec LESS_COMMA
|	CoordinateSystemOpt Expression ',' CoordinateSystemOpt Expression ',' CoordinateSystemOpt Expression ',' CoordinateSystemOpt Expression

PrimaryExpression:
	Operand
|	IDENTIFIER '(' ExpressionList ')'
|	PrimaryExpression '[' SliceArgument ':' SliceArgument ']'

PrimaryNonParenthesizedExpression:
	NonParenthesizedOperand
|	IDENTIFIER '(' ExpressionList ')'
|	PrimaryNonParenthesizedExpression '[' SliceArgument ':' SliceArgument ']'

PrimaryNonStringExpression:		
	NonStringOperand		
|	IDENTIFIER '(' ExpressionList ')'
|	PrimaryNonStringExpression '[' SliceArgument ':' SliceArgument ']'

Print:
	"print" ExpressionList

Range:
	'[' ':' ']'
|	'[' ':' RangeExpression ']'
|	'[' ']'
|	'[' RangeExpression ':' ']'
|	'[' RangeExpression ':' RangeExpression ']'

RangeExpression:
	'*'
|	RangeExpression "!=" RangeExpression
|	RangeExpression "&&" RangeExpression
|	RangeExpression "**" RangeExpression
|	RangeExpression "<<" RangeExpression
|	RangeExpression "<=" RangeExpression
|	RangeExpression "==" RangeExpression
|	RangeExpression ">=" RangeExpression
|	RangeExpression ">>" RangeExpression
|	RangeExpression "eq" RangeExpression
|	RangeExpression "ne" RangeExpression
|	RangeExpression "||" RangeExpression
|	RangeExpression '%' RangeExpression
|	RangeExpression '&' RangeExpression
|	RangeExpression '*' RangeExpression
|	RangeExpression '+' RangeExpression
|	RangeExpression '-' RangeExpression
|	RangeExpression '.' RangeExpression
|	RangeExpression '/' RangeExpression
|	RangeExpression '<' RangeExpression
|	RangeExpression '=' RangeExpression
|	RangeExpression '>' RangeExpression
|	RangeExpression '?' RangeExpression ':' RangeExpression
|	RangeExpression '^' RangeExpression
|	RangeExpression '|' RangeExpression
|	UnaryExpression

Ranges:
	Range
|	Ranges	Range

RangesOpt:
	/* empty */ {}
|	Ranges

Replot:
	"rep"
|	"rep" PlotElementList
|	"replot"
|	"replot" PlotElementList

Reread:
	"reread"

Reset:
	"reset"
|	"reset" "bind"
|	"reset" "errors"
|	"reset" "session"

Set:
	"set" IterationSpecifierOpt SetSpec

SetSpec:
	"angle" SetAnglesSpec
|	"angles" SetAnglesSpec
|	"arrow" SetArrowSpec
|	"auto" SetAutoscaleSpecListOpt
|	"autoscale" SetAutoscaleSpecListOpt
|	"bars" SetBarsSpecListOpt
|	"bmargin" SetBmarginSpecOpt
|	"border" SetBorderSpec
|	"boxwidth" SetBoxwidthSpec
|	"cbdata" "time"
|	"cbdtics"
|	"cblabel" SetXLabelSpecOpt
|	"cbmtics"
|	"cbrange" SetRangeSpec
|	"cbtics" SetXTicsSpecListOpt
|	"clabel" Expression
|	"clip" SetClipSpecOpt
|	"cntrlabel" SetCntrlabelSpecList
|	"cntrp" SetCntrparamSpecList
|	"cntrparam" SetCntrparamSpecList
|	"colorbox" SetColorboxSpecListOpt
|	"colorsequence" SetColorsequenceSpecOpt
|	"contour" SetContourSpec 
|	"dashtype" DashTypeSpec
|	"datafile" SetDatafileSpec
|	"decimalsign" SetDecimalsignSpecOpt
|	"dgrid3d" SetDgrid3dSpecListOpt
|	"dummy" IdentifierOptList
|	"encoding" SetEncodingSpec
|	"fit" SetFitSpecList
|	"fontpath" SetFontPathSpecOpt
|	"format" SetFormatSpec
|	"grid" SetGridSpecListOpt
|	"hidden3d" SetHidden3dSpecListOpt
|	"history" SetHistorySpecListOpt
|	"iso" ExpressionList
|	"isosamples" ExpressionList
|	"key" SetKeySpecListOpt
//yy:example "set label 1 'foo'"
|	"label" SetLabelSpec
|	"linetype" Expression LineStyleList
|	"link" SetLinkSpecListOpt
|	"lmargin" SetBmarginSpecOpt
|	"loadpath" SetFontPathSpecOpt
|	"locale"
|	"locale" Expression
|	"log" SetLogscaleSpec
|	"logscale" SetLogscaleSpec
|	"macros"
|	"mapping" SetMappingSpec
|	"margins" ExpressionList
|	"mcbtics" SetMxticsSpecOpt
|	"mono" SetMonochromeSpecOpt
|	"monochrome" SetMonochromeSpecOpt
|	"mouse" SetMouseSpecListOpt
|	"multiplot" SetMultiplotSpecListOpt
|	"mx2tics" SetMxticsSpecOpt
|	"mxtics" SetMxticsSpecOpt
|	"my2tics" SetMxticsSpecOpt
|	"mytics" SetMxticsSpecOpt
|	"mztics" SetMxticsSpecOpt
|	"noxtics"
|	"noytics"
|	"object" Expression SetObjectSpecList 
|	"offset" SetOffsetsSpecOpt
|	"offsets" SetOffsetsSpecOpt
|	"origin" Expression ',' Expression
|	"output" ExpressionOpt
|	"pal" SetPaletteSpecListOpt
|	"palette" SetPaletteSpecListOpt
|	"para"
|	"parametric"
|	"paxis" Expression SetPaxisSpecListOpt
|	"pm3d" SetPm3dSpecListOpt
|	"pointintervalbox" Expression
|	"pointsize" Expression
|	"polar"
|	"print" SetPrintSpecOpt
|	"psdir" Expression
|	"raxis" 
|	"rmargin" SetBmarginSpecOpt
|	"rrange" SetRangeSpec
|	"rtics" SetXTicsSpecListOpt
|	"sam" ExpressionList
|	"sample" ExpressionList
|	"samples" ExpressionList
|	"size" SetSizeSpecList
|	"style" SetStyleSpec
|	"surface" SetSurfaceSpecOpt
|	"table" SetTableSpecOpt
|	"term" SetTerminalSpec
|	"terminal" SetTerminalSpec
|	"termoption" SetTermoptionSpec
|	"tic" SetXTicsSpecListOpt
|	"tics" SetXTicsSpecListOpt
|	"ticslevel" Expression
|	"time"
|	"timefmt" Expression
|	"timestamp" SetTimestampSpecListOpt
|	"title" SetTitleSpecOpt
|	"tmargin" SetBmarginSpecOpt
|	"trange" SetRangeSpec
|	"urange" SetRangeSpec
|	"vi" SetViewSpec
|	"view" SetViewSpec
|	"vrange" SetRangeSpec
|	"x2data" "time"
|	"x2dtics"
|	"x2label" SetXLabelSpecOpt
|	"x2mtics"
|	"x2range" SetRangeSpec
|	"x2tics" SetXTicsSpecListOpt
|	"x2zeroaxis" SetZeroaxisSpecListOpt
|	"xdata" "time"
|	"xdtics"
|	"xlabel" SetXLabelSpecOpt
|	"xmtics"
|	"xrange" SetRangeSpec
|	"xtics" SetXTicsSpecListOpt
|	"xyplane" SetXyplaneSpec
|	"xzeroaxis" SetZeroaxisSpecListOpt
|	"y2data" "time"
|	"y2dtics"
|	"y2label" SetXLabelSpecOpt
|	"y2mtics"
|	"y2range" SetRangeSpec
|	"y2tics" SetXTicsSpecListOpt
|	"y2zeroaxis" SetZeroaxisSpecListOpt
|	"ydata" "time"
|	"ydtics"
|	"ylabel" SetXLabelSpecOpt
|	"ymtics"
|	"yrange" SetRangeSpec
|	"ytics" SetXTicsSpecListOpt
|	"yzeroaxis" SetZeroaxisSpecListOpt
|	"zdata" "time"
|	"zdtics"
|	"zero" Expression
|	"zeroaxis" SetZeroaxisSpecListOpt
|	"zlabel" SetXLabelSpecOpt
|	"zmtics"
|	"zrange" SetRangeSpec
|	"ztics" SetXTicsSpecListOpt
|	"zzeroaxis" SetZeroaxisSpecListOpt

/*
set angles {degrees | radians}
*/
SetAnglesSpec:
	"degrees"
|	"radians"
|	"rad"

/*
set arrow {<tag>} from <position> to <position>
set arrow {<tag>} from <position> rto <position>
set arrow {<tag>} from <position> length <coord> angle <ang>
set arrow <tag> arrowstyle | as <arrow_style>
set arrow <tag> {nohead | head | backhead | heads}
	{size <headlength>,<headangle>{,<backangle>}}
	{filled | empty | nofilled | noborder}
	{front | back}
	{linestyle <line_style>}
	{linetype <line_type>} {linewidth <line_width>}
	{linecolor <colorspec>} {dashtype <dashtype>}
*/
SetArrowSpec:
	ExpressionOpt SetArrowSpecList

SetArrowSpecList:
	SetArrowSpecListItem
|	SetArrowSpecList SetArrowSpecListItem


SetArrowSpecListItem:
	"head"
|	"nohead"
|	"backhead"
|	"heads"
|	"size" Expression ',' Expression
|	"size" Expression ',' Expression ',' Expression
|	"fill" %prec LESS_STYLE
|	"filled"
|	"nofilled"
|	"empty"
|	"noborder"
|	"front"
|	"back"
|	LineStyleListItem
|	"from" Position "to" Position
|	"from" Position "rto" Position
|	"from" Position "length" Position "angle" Position
|	"arrowstyle"
|	"as" Expression

SetAutoscaleAxes:
	"cb"
|	"cbfix"
|	"cbfixmax"
|	"cbfixmin"
|	"cbmax"
|	"cbmin"
|	"x"
|	"x2"
|	"x2fix"
|	"x2fixmax"
|	"x2fixmin"
|	"x2max"
|	"x2min"
|	"xfix"
|	"xfixmax"
|	"xfixmin"
|	"xmax"
|	"xmin"
|	"xy"
|	"xyfix"
|	"xyfixmax"
|	"xyfixmin"
|	"y"
|	"y2"
|	"y2fix"
|	"y2fixmax"
|	"y2fixmin"
|	"y2max"
|	"y2min"
|	"yfix"
|	"yfixmax"
|	"yfixmin"
|	"ymax"
|	"ymin"
|	"z"
|	"zfix"
|	"zfixmax"
|	"zfixmin"
|	"zmax"

/*
set autoscale
	{
		<axes> {|min|max|fixmin|fixmax|fix} | fix | keepfix
	}
set autoscale noextend
*/
SetAutoscaleSpecList:
	SetAutoscaleSpecListItem
|	SetAutoscaleSpecList SetAutoscaleSpecListItem

SetAutoscaleSpecListOpt:
	/* empty */ {}
|	SetAutoscaleSpecList

SetAutoscaleSpecListItem:
	"fix"
|	"keepfix"
|	"noextend"
|	SetAutoscaleAxes

/*
set bars {small | large | fullwidth | <size>} {front | back}
*/
SetBarsSpecList:
	SetBarsSpecListItem
|	SetBarsSpecList SetBarsSpecListItem

SetBarsSpecListItem:
	"small"
|	"large"
|	"fullwidth"
|	SimpleExpression
|	"front"
|	"back"

SetBarsSpecListOpt:
	/* empty */ {}
|	SetBarsSpecList

/*
set bmargin {{at screen} <margin>}
*/
SetBmarginSpecOpt:
	/* empty */ {}
|	"at" "screen" Expression
|	Expression

/*
set border {<integer>}
	{front | back | behind} {linewidth | lw <line_width>}
	{{linestyle | ls <line_style>} | {linetype | lt <line_type>}}
*/
//yy:example "set border 1 front"
SetBorderSpec:
	ExpressionOpt SetBorderSpecListOpt

SetBorderSpecList:
	SetBorderSpecListItem
|	SetBorderSpecList SetBorderSpecListItem

SetBorderSpecListItem:
	"front"
|	"back"
|	"behind"
|	LineStyleListItem

SetBorderSpecListOpt:
	/* empty */ {}
|	SetBorderSpecList

/*
set boxwidth {<width>} {absolute|relative}
*/
SetBoxwidthSpec:
	Expression
|	Expression "absolute"
|	Expression "relative"

/*
set clip {points|one|two}
*/
SetClipSpecOpt:
	/* empty */ {}
|	"points"
|	"one"
|	"two"

/*
set cntrlabel {format "format"} {font "font"}
set cntrlabel {start <int>} {interval <int>}
set cntrlabel onecolor
*/
SetCntrlabelSpecList:
	SetCntrlabelSpecListItem
|	SetCntrlabelSpecList SetCntrlabelSpecListItem

SetCntrlabelSpecListItem:
	"format" Expression
|	"font" Expression
|	"start" Expression
|	"interval" Expression
|	"onecolor"

/*
set cntrparam { 
	{ linear
	| cubicspline
	| bspline
	| points <n>
	| order <n>
	| levels { auto {<n>} | <n>
		| discrete <z1> {,<z2>{,<z3>...}}
		| incremental <start>, <incr> {,<end>}
		}
	}
}
*/
SetCntrparamSpecList:
	SetCntrparamSpecListItem
|	SetCntrparamSpecList SetCntrparamSpecListItem

SetCntrparamSpecListItem:
	"linear"
|	"cubicspline"
|	"bspline"
|	"points" Expression
|	"order" Expression
|	"level" "auto" Expression
|	"level" Expression
|	"level" "discrete" ExpressionList
|	"level" "incr" ExpressionList
|	"level" "incremental" ExpressionList
|	"levels" "auto" Expression
|	"levels" Expression
|	"levels" "discrete" ExpressionList
|	"levels" "incr" ExpressionList
|	"levels" "incremental" ExpressionList

/*
set colorsequence {default|classic|podo}
*/
SetColorsequenceSpecOpt:
	/* empty */
|	"default"
|	"classic"
|	"podo"

/*
set colorbox
set colorbox {
		{ vertical | horizontal }
		{ default | user }
		{ origin x, y }
		{ size x, y }
		{ front | back }
		{ noborder | bdefault | border [line style] }
	}
*/
SetColorboxSpecList:
	SetColorboxSpecListItem
|	SetColorboxSpecList SetColorboxSpecListItem
		     	
SetColorboxSpecListItem:
	"vertical"
|	"horizontal"
|	"default"
|	"user"
|	"origin" Expression ',' Expression
|	"size" Expression ',' Expression
|	"front"
|	"back"
|	"noborder"
|	"bdefault"
|	"border" LineStyleList

SetColorboxSpecListOpt:
	/* empty */ {}
|	SetColorboxSpecList

/*
set contour {base | surface | both}
*/
SetContourSpec:
	/* empty */ {}
|	"base"
|	"surface"
|	"both"

SetFontPathSpecOpt:
	/* empty */ {}
|	Expression
|	Expression SimpleExpressionList

SetEncodingSpec:
	"cp1250"
|	"cp1251"
|	"cp1252"
|	"cp1254"
|	"cp437"
|	"cp850"
|	"cp852"
|	"cp950"
|	"default"
|	"iso_8859_1"
|	"iso_8859_15"
|	"iso_8859_2"
|	"iso_8859_9"
|	"koi8r"
|	"koi8u"
|	"locale"
|	"sjis"
|	"utf8"
|	Expression

/*
set datafile fortran
set datafile nofpe trap
set datafile missing "<string>"
set datafile separator {whitespace | tab | comma | "<chars>"}
set datafile commentschars {"<string>"}
set datafile binary <binary list>
*/
SetDatafileSpec:
	"fortran"
|	"nofpe" "trap"
|	"missing" Expression
|	"sep" SetDatafileSeperatorSpecOpt
|	"separator" SetDatafileSeperatorSpecOpt
|	"commentschars"
|	"commentschars" Expression
|	"binary"
|	"binary" BinaryList

SetDatafileSeperatorSpecOpt:
	/* empty */
|	"whitespace"
|	"tab"
|	"comma"
|	Expression

/*
set decimalsign {<value> | locale {"<locale>"}}
*/
SetDecimalsignSpecOpt:
	/* empty */ {}
|	Expression
|	"locale"
|	"locale" Expression

/*
set dgrid3d {<rows>} {,{<cols>}}
	{ 
		splines | qnorm {<norm>} | (gauss | cauchy | exp | box | hann)
		{kdensity} {<dx>} {,<dy>} 
	}
*/
SetDgrid3dSpecList:
	SetDgrid3dSpecListItem
|	SetDgrid3dSpecList SetDgrid3dSpecListItem

SetDgrid3dSpecListItem:
	Expression %prec LESS_ADD_SUB
|	','
|	"splines"
|	"qnorm"
|	"gauss"
|	"cauchy"
|	"exp"
|	"box"
|	"hann"
|	"kdensity"

SetDgrid3dSpecListOpt:
	/* empty */ {}
|	SetDgrid3dSpecList

/*
set fit {nolog | logfile {"<filename>"|default}}
	{{no}quiet|results|brief|verbose}
	{{no}errorvariables}
	{{no}covariancevariables}
	{{no}errorscaling}
	{{no}prescale}
	{maxiter <value>|default}
	{limit <epsilon>|default}
	{limit_abs <epsilon_abs>}
	{start_lambda <value>|default}
	{lambda_factor <value>|default}
	{script {"<command>"|default}}
	{v4 | v5}
*/
SetFitSpecList:
	SetFitSpecListItem
|	SetFitSpecList SetFitSpecListItem

SetFitSpecListItem:
	"nolog"
|	"logfile" Expression
|	"logfile" "default"
|	"quiet"
|	"noquiet"
|	"results"
|	"brief"
|	"verbose"
|	"errorvariables"
|	"noerrorvariables"
|	"covariancevariables"
|	"nocovariancevariables"
|	"errorscaling"
|	"noerrorscaling"
|	"prescale"
|	"noprescale"
|	"maxiter" Expression
|	"maxiter" "default"
|	"limit" Expression
|	"limit" "default"
|	"limit_abs" Expression
|	"start_lambda" Expression
|	"start_lambda" "default"
|	"lambda_factor" Expression
|	"lambda_factor" "default"
|	"script" Expression
|	"script" "default"
|	"v4"
|	"v5"

SetFormatAxesOpt:
	/* empty */ {}
|	"cb"
|	"x"
|	"x2"
|	"xy"
|	"y"
|	"y2"
|	"z"

/*
set format {<axes>} {"<format-string>"} {numeric|timedate|geographic}
*/
//yy:example "set format x 'foo' numeric"
SetFormatSpec:
	SetFormatAxesOpt ExpressionOpt SetFormatModifierOpt

SetFormatModifierOpt:
	/* empty */ {}
|	"numeric"
|	"timedate"
|	"geographic"

/*
set grid
	{{no}{m}xtics}
	{{no}{m}ytics}
	{{no}{m}ztics}
	{{no}{m}x2tics} 
	{{no}{m}y2tics}
	{{no}{m}cbtics}
	{polar {<angle>}}
	{layerdefault | front | back}
	{ 
		{linestyle <major_linestyle>}
		| {linetype  lt <major_linetype>}
		{linewidth | lw <major_linewidth>}
		{ 
			, {linestyle | ls <minor_linestyle>}
			| {linetype | lt <minor_linetype>}
			{linewidth | lw <minor_linewidth>} 
		}
	}
*/
SetGridSpecList:
	SetGridSpecListItem
|	SetGridSpecList SetGridSpecListItem

SetGridSpecListItem:
	"back"
|	"cbtics"
|	"front"
|	"layerdefault"
|	"mcb"
|	"mcbtics"
|	"mx"
|	"mx2"
|	"mx2tics"
|	"mxtics"
|	"my"
|	"my2"
|	"my2tics"
|	"mytics"
|	"mz"
|	"mztics"
|	"nocbtics"
|	"nomcbtics"
|	"nomx2tics"
|	"nomxtics"
|	"nomy2tics"
|	"nomytics"
|	"nomztics"
|	"nox2tics"
|	"noxtics"
|	"noy2tics"
|	"noytics"
|	"noztics"
|	"polar"
|	"polar" Expression
|	"x2tics"
|	"xtics"
|	"y2tics"
|	"ytics"
|	"ztics"
|	LineStyleListItem
|	LineStyleListItem ',' LineStyleListItem
|	SetLogscaleAxesListItem

SetGridSpecListOpt:
	/* empty */ {}
|	SetGridSpecList

/*
set hidden3d {defaults} |
	{ 
		{front|back}
		{{offset <offset>} | {nooffset}}
		{trianglepattern <bitpattern>}
		{{undefined <level>} | {noundefined}}
		{{no}altdiagonal}
		{{no}bentover} 
	}
*/
SetHidden3dSpecList:
	SetHidden3dSpecListItem
|	SetHidden3dSpecList SetHidden3dSpecListItem

SetHidden3dSpecListItem:
	"defaults"
|	"front"
|	"back"
|	"offset" Expression
|	"nooffset"
|	"trianglepattern" Expression
|	"undefined" Expression
|	"noundefined"
|	"altdiagonal"
|	"noaltdiagonal"
|	"bentover"
|	"nobentover"

SetHidden3dSpecListOpt:
	/* empty */ {}
|	SetHidden3dSpecList

/*
set history {size <N>} {quiet|numbers} {full|trim} {default}
*/
SetHistorySpecList:
	SetHistorySpecListItem
|	SetHistorySpecList SetHistorySpecListItem

SetHistorySpecListItem:
	"size" Expression
|	"quiet"
|	"numbers"
|	"full"
|	"trim"
|	"default"

SetHistorySpecListOpt:
	/* empty */ {}
|	SetHistorySpecList

/*
set key {on|off} {default}
	{{inside | outside} | {lmargin | rmargin | tmargin | bmargin}
		| {at <position>}}
	{left | right | center} {top | bottom | center}
	{vertical | horizontal} {Left | Right}
	{{no}opaque}
	{{no}reverse} {{no}invert}
	{samplen <sample_length>} {spacing <vertical_spacing>}
	{width <width_increment>} {height <height_increment>}
	{{no}autotitle {columnheader}}
	{title "<text>"} {{no}enhanced}
	{font "<face>,<size>"} {textcolor <colorspec>}
	{{no}box {linestyle <style> | linetype <type> | linewidth <width>}}
	{maxcols {<max no. of columns> | auto}}
	{maxrows {<max no. of rows> | auto}}
*/
SetKeySpecList:
	SetKeySpecListItem
|	SetKeySpecList SetKeySpecListItem

SetKeySpecListItem:
	"on"
|	"off"
|	"default"
|	"inside"
|	"out"
|	"outside"
|	"above"
|	"below"
|	"under"
|	"lmargin"
|	"rmargin"
|	"tmargin"
|	"bmargin"
|	"at" Position
|	"left"
|	"right"
|	"center"
|	"top"
|	"bot"
|	"bottom"
|	"vertical"
|	"horizontal"
|	"Left"
|	"Right"
|	"opaque"
|	"noopaque"
|	"reverse"
|	"noreverse"
|	"invert"
|	"noinvert"
|	"sample" Expression
|	"samplen" Expression
|	"spacing" Expression
|	"width" Expression
|	"height" Expression
|	"autotitle"
|	"column"
|	"columnhead"
|	"columnheader"
|	"noautotitle"
|	"title" Expression
|	"enhanced"
|	"noenhanced"
|	"font" Expression
|	"textcolor" ColorSpec
|	"box"
|	"nobox"
|	LineStyleListItem
|	"maxcols" Expression
|	"maxcols" "auto"
|	"maxrows" Expression
|	"maxrows" "auto"

SetKeySpecListOpt:
	/* empty */ {}
|	SetKeySpecList

/*
set label {<tag>} {"<label text>"} {at <position>}
	{left | center | right}
	{norotate | rotate {by <degrees>}}
	{font "<name>{,<size>}"}
	{noenhanced}
	{front | back}
	{textcolor <colorspec>}
	{point <pointstyle> | nopoint}
	{offset <offset>}
	{boxed}
	{hypertext}
*/
//yy:example "set label 1 'foo'"
SetLabelSpec:
	ExpressionOpt SetLabelSpecList

//yy:example "set label 1 'foo'"
SetLabelSpecList:
	SetLabelSpecListItem
//yy:example "set label 1 'foo' left"
|	SetLabelSpecList SetLabelSpecListItem

//yy:example "set label 1 'foo'"
SetLabelSpecListItem:
	SimpleExpression
|	"at" Position
|	"left"
|	"center"
|	"right"
|	"norotate"
|	"rotate"
|	"rotate" "by" Expression
|	"font" Expression
|	"noenhanced"
|	"front"
|	"back"
|	"textcolor" ColorSpec
|	"point"
|	"nopoint"
|	"offset" Expression %prec LESS_COMMA
|	"offset" Expression ',' Expression
|	"boxed"
|	"hypertext"
|	LineStyleListItem

SetLinkSpecList:
	SetLinkSpecListItem
|	SetLinkSpecList SetLinkSpecListItem

SetLinkSpecListItem:
	"x"
|	"y"
|	"x2"
|	"y2"
|	"via" Expression "inverse" Expression

SetLinkSpecListOpt:
	/* empty */ {}
|	SetLinkSpecList

/*
set logscale <axes> {<base>}
*/
//yy:example "set logscale x 10"
SetLogscaleSpec:
	SetLogscaleAxesListOpt ExpressionOpt

SetLogscaleAxesList:
	SetLogscaleAxesListItem
|	SetLogscaleAxesList SetLogscaleAxesListItem

SetLogscaleAxesListItem:
	"x"
|	"x2"
|	"y"
|	"y2"
|	"z"
|	"cb"
|	"r"

SetLogscaleAxesListOpt:
	/* empty */
|	SetLogscaleAxesList


/*
set mapping {cartesian | spherical | cylindrical}
*/
SetMappingSpec:
	"cartesian"
|	"spherical"
|	"cylindrical"

/*
set monochrome {linetype N <linetype properties>}
*/
SetMonochromeSpecOpt:
	/* empty */ {}
|	"linetype" Expression LineStyleList

/*
set mouse {doubleclick <ms>} {nodoubleclick}
	{{no}zoomcoordinates}
	{zoomfactors <xmultiplier>, <ymultiplier>}
	{noruler | ruler {at x,y}}
	{polardistance{deg|tan} | nopolardistance}
	{format <string>}
	{mouseformat <int>/<string>}
	{{no}labels {"labeloptions"}}
	{{no}zoomjump} {{no}verbose}
*/
SetMouseSpecList:
	SetMouseSpecListItem
|	SetMouseSpecList SetMouseSpecListItem

SetMouseSpecListItem:
	"doubleclick" Expression
|	"nodoubleclick"
|	"zoomcoordinates"
|	"nozoomcoordinates"
|	"zoomfactors" Expression ',' Expression
|	"noruler"
|	"ruler" "at" Expression ',' Expression
|	"polardistancedeg"
|	"polardistancetan"
|	"nopolardistance"
|	"format" Expression
|	"mouseformat" Expression
|	"labels"
|	"labels" Expression
|	"nolabels"
|	"nolabels" Expression
|	"zoomjump"
|	"nozoomjump"
|	"verbose"
|	"noverbose"

SetMouseSpecListOpt:
	/* empty */
|	SetMouseSpecList

/*
set multiplot
	{ title <page title> {font <fontspec>} {enhanced|noenhanced} }
	{ layout <rows>,<cols>
		{rowsfirst|columnsfirst} {downwards|upwards}
		{scale <xscale>{,<yscale>}} {offset <xoff>{,<yoff>}}
		{margins <left>,<right>,<bottom>,<top>}
		{spacing <xspacing>{,<yspacing>}}
	}
set multiplot {next|previous}
*/
SetMultiplotSpecList:
	SetMultiplotSpecListItem
|	SetMultiplotSpecList SetMultiplotSpecListItem

SetMultiplotSpecListItem:
	"title" Expression
|	"font" Expression
|	"enhanced"
|	"noenhanced"
|	"layout" Expression ',' Expression
|	"rowsfirst"
|	"columnsfirst"
|	"downwards"
|	"upwards"
|	"scale" Position
|	"offset" Position
|	"margins" Position
|	"spacing" Position
|	"next"
|	"previous"

SetMultiplotSpecListOpt:
	/* empty */
|	SetMultiplotSpecList

/*
set object <index>
	<object-type> <object-properties>
	{front|back|behind} {clip|noclip}
	{fc|fillcolor <colorspec>} {fs <fillstyle>}
	{default} {lw|linewidth <width>} {dt|dashtype <dashtype>}
*/
SetObjectSpecList:
	SetObjectSpecListItem
|	SetObjectSpecList SetObjectSpecListItem

SetObjectSpecListItem:
	"front"
|	"back"
|	"behind"
|	"clip"
|	"noclip"
|	"fc" ColorSpec
|	"fc" "lt" ColorSpec
|	"fillcolor" ColorSpec
|	"fillcolor" "lt" ColorSpec
|	"fs" SetStyleFillSpecList
|	"fillstyle" SetStyleFillSpecList
|	"default"
|	"lw" Expression
|	"linewidth" Expression
|	"dt" DashTypeSpec
|	"dashtype" DashTypeSpec
|	"rectangle"
|	"from" Position "to" Position
|	"from" Position "rto" Position
|	"center" Position "size" Position
|	"at" Position "size" Position
|	"at" Position "radius" Position
|	"ellipse"
|	"angle" Expression
|	"units" "xy"
|	"units" "xx"
|	"units" "yy"
|	"circle"
|	"arc" '[' Expression ':' Expression ']'
|	"polygon"
|	"to" Position
|	"rto" Position

/*
set offsets <left>, <right>, <top>, <bottom>
*/
SetOffsetsSpecOpt:
	/* empty */ {}
|	Expression ',' Expression
|	Expression ',' Expression ',' Expression ',' Expression

/*
set palette
set palette {
	{ gray | color }
	{ gamma <gamma> }
	{ rgbformulae <r>,<g>,<b>
		| defined { ( <gray1> <color1> {, <grayN> <colorN>}... ) }
		| file ’<filename>’ {datafile-modifiers}
		| functions <R>,<G>,<B>
	}
	{ cubehelix {start <val>} {cycles <val>} {saturation <val>} }
	{ model { RGB | HSV | CMY | YIQ | XYZ } }
	{ positive | negative }
	{ nops_allcF | ps_allcF }
	{ maxcolors <maxcolors> }
}
*/
SetPaletteSpecList:
	SetPaletteSpecListItem
|	SetPaletteSpecList SetPaletteSpecListItem

//yy:field	Data	[]byte	// Content of the inline data block.
SetPaletteSpecListItem:
	"gray"
|	"color"
|	"gamma" Expression
|	"rgb" Expression ',' Expression ',' Expression
|	"rgbformulae" Expression ',' Expression ',' Expression
|	"defined"
|	"defined" '(' SetPalleteDefinedColorList ')'
|	"file" Expression DatafileModifiersListOpt
	{
		lhs.post(lx)
	}
|	"func" Expression ',' Expression ',' Expression
|	"functions" Expression ',' Expression ',' Expression
|	"cubehelix"
|	"start" Expression
|	"cycles" Expression
|	"saturation" Expression
|	"mode" "RGB"
|	"mode" "HSV"
|	"mode" "CMY"
|	"mode" "YIQ"
|	"mode" "XYZ"
|	"model" "RGB"
|	"model" "HSV"
|	"model" "CMY"
|	"model" "YIQ"
|	"model" "XYZ"
|	"positive"
|	"negative"
|	"nops_allcF"
|	"ps_allcF"
|	"maxcolors" Expression

SetPaletteSpecListOpt:
	/* empty */ {}
|	SetPaletteSpecList

SetPalleteDefinedColorList:
	SetPalleteDefinedColorListItem
|	SetPalleteDefinedColorList ',' SetPalleteDefinedColorListItem

SetPalleteDefinedColorListItem:
	Expression SimpleExpression SimpleExpression SimpleExpression
|	Expression SimpleExpression

/*
set paxis <axisno> {range <range-options> | tics <tic-options>}
*/
SetPaxisSpecList:
	SetPaxisSpecListItem
|	SetPaxisSpecList SetPaxisSpecListItem

SetPaxisSpecListItem:
	"range" SetRangeSpecList
|	"tics" SetXTicsSpecListOpt

SetPaxisSpecListOpt:
	/* empty */ {}
|	SetPaxisSpecList

/*
set pm3d {
		{ at <position> }
		{ interpolate <steps/points in scan, between scans> }
		{ scansautomatic | scansforward | scansbackward | depthorder }
		{ flush { begin | center | end } }
		{ ftriangles | noftriangles }
		{ clip1in | clip4in }
		{ corners2color
			{ mean|geomean|harmean|rms|median|min|max|c1|c2|c3|c4 }
		}
		{ hidden3d {<linestyle>} | nohidden3d }
		{ implicit | explicit }
		{ map }
	}
*/
SetPm3dSpecList:
	SetPm3dSpecListItem
|	SetPm3dSpecList SetPm3dSpecListItem

SetPm3dSpecListItem:
	"at" Position
|	"interpolate" Expression ',' Expression
|	"scansautomatic"
|	"scansforward"
|	"scansbackward"
|	"depthorder"
|	"flush"
|	"begin"
|	"center"
|	"end"
|	"ftriangles"
|	"noftriangles"
|	"clip1in"
|	"clip4in"
|	"corners2color"
|	"mean"
|	"geomean"
|	"harmean"
|	"rms"
|	"median"
|	"min"
|	"max"
|	"c1"
|	"c2"
|	"c3"
|	"c4"
|	"hidden3d"
|	"hidden3d" Expression
|	"implicit"
|	"explicit"
|	"map"
|	"border"
|	LineStyleListItem

SetPm3dSpecListOpt:
	/* empty */ {}
|	SetPm3dSpecList

/*
set mxtics {<freq> | default}
The same syntax applies to mytics, mztics, mx2tics, my2tics, mrtics and mcbtics.
*/
SetMxticsSpecOpt:
	/* empty */ {}
|	"default"
|	Expression

SetPrintSpecOpt:
	/* empty */ {}
|	Expression
|	Expression "append"

/*
set xrange 
	[{{<min>}:{<max>}}] {{no}reverse} {{no}writeback} {{no}extend}
	| restore
The same syntax applies to yrange, zrange, x2range, y2range, cbrange, rrange, trange, urange and
vrange.
*/
SetRangeSpec:
	Range SetRangeSpecListOpt
|	"restore"

SetRangeSpecList:
	SetRangeSpecListItem
|	SetRangeSpecList SetRangeSpecListItem

SetRangeSpecListItem:
	"reverse"
|	"noreverse"
|	"writeback"
|	"nowriteback"
|	"extend"
|	"noextend"
|	Range

SetRangeSpecListOpt:
	/* empty */ {}
|	SetRangeSpecList

/*
set size
	{{no}square | ratio <r> | noratio} 
	{<xscale>,<yscale>}
*/
SetSizeSpecList:
	SetSizeSpecListItem
|	SetSizeSpecList SetSizeSpecListItem

SetSizeSpecListItem:
	"square"
|	"nosquare"
|	"ratio" Expression
|	"noratio"
|	SimpleExpression ',' Expression

/*
set style boxplot 
	{range <r> | fraction <f>}
	{{no}outliers}
	{pointtype <p>}
	{candlesticks | financebars}
	{separation <x>}
	{labels off | auto | x | x2}
	{sorted | unsorted}
*/
SetStyleBoxplotSpecList:
	SetStyleBoxplotSpecListItem
|	SetStyleBoxplotSpecList SetStyleBoxplotSpecListItem

SetStyleBoxplotSpecListItem:
	"range" Expression
|	"fraction" Expression
|	"outliers"
|	"nooutliers"
|	"pointtype" Expression
|	"candlesticks"
|	"financebars"
|	"separation" Expression
|	"labels" "off"
|	"labels" "auto"
|	"labels" "x"
|	"labels" "x2"
|	"sorted"
|	"unsorted"

/*
set style fill 
	{empty | {transparent} solid {<density>} | {transparent} pattern {<n>}}
	{border {lt} {lc <colorspec>} | noborder}
*/
SetStyleFillSpecList:
	SetStyleFillSpecListItem
|	SetStyleFillSpecList SetStyleFillSpecListItem

SetStyleFillSpecListItem:
	"empty"
|	"transparent"
|	"solid" %prec LESS_EXPR
|	"solid" Expression
|	"pattern" Expression
|	"bo" %prec LESS_EXPR
|	"bo" ColorSpec
|	"border" %prec LESS_EXPR
|	"border" ColorSpec
|	"lt" ColorSpec
|	"lc" ColorSpec
|	"noborder"

SetStyleSpec:
	"arrow" Expression "default"
|	"arrow" Expression ArrowStyleList
|	"boxplot" SetStyleBoxplotSpecList
|	"data" PlotElementStyle
|	"fill" SetStyleFillSpecList
|	"func" PlotElementStyle
|	"function" PlotElementStyle
|	"line" Expression LineStyleList
|	"circle" SetStyleCircleSpecListOpt
|	"ellipse" SetStyleEllipseSpecListOpt
|	"histogram" PlotElementStyleHistogramsListOpt
|	"increment"
|	"increment" "default"
|	"increment" "userstyles"
|	"rectangle" SetStyleRectangleSpecListOpt
|	"textbox" SetStyleTextboxSpecListOpt

/*
set style circle {radius {graph|screen} <R>}
	{{no}wedge}
	{clip|noclip}
*/
SetStyleCircleSpecList:
	SetStyleCircleSpecListItem
|	SetStyleCircleSpecList SetStyleCircleSpecListItem

SetStyleCircleSpecListItem:
	"radius" Position
|	"wedge"
|	"nowedge"
|	"clip"
|	"noclip"

SetStyleCircleSpecListOpt:
	/* empty */ {}
|	SetStyleCircleSpecList

/*
set style ellipse {units xx|xy|yy}
	{size {graph|screen} <a>, {{graph|screen} <b>}}
	{angle <angle>}
	{clip|noclip}
*/
SetStyleEllipseSpecList:
	SetStyleEllipseSpecListItem
|	SetStyleEllipseSpecList SetStyleEllipseSpecListItem

SetStyleEllipseSpecListItem:
	"units" "xx"
|	"units" "xy"
|	"units" "yy"
|	"size" Position
|	"angle" Expression
|	"clip"
|	"noclip"

SetStyleEllipseSpecListOpt:
	/* empty */ {}
|	SetStyleEllipseSpecList

/*
set style rectangle {front|back} {lw|linewidth <lw>}
	{fillcolor <colorspec>} {fs <fillstyle>}
*/
SetStyleRectangleSpecList:
	SetStyleRectangleSpecListItem
|	SetStyleRectangleSpecList SetStyleRectangleSpecListItem

SetStyleRectangleSpecListItem:
	"front"
|	"back"
|	"lw" Expression
|	"linewidth" Expression
|	"fillcolor" ColorSpec
|	"fc" ColorSpec
|	"fs" SetStyleFillSpecList

SetStyleRectangleSpecListOpt:
	/* empty */ {}
|	SetStyleRectangleSpecList

/*
set style textbox {opaque|transparent}{{no}border}
*/
SetStyleTextboxSpecList:
	SetStyleTextboxSpecListItem
|	SetStyleTextboxSpecList	SetStyleTextboxSpecListItem

SetStyleTextboxSpecListItem:
	"opaque"
|	"transparent"
|	"border"
|	"noborder"
|	"margins" Expression ',' Expression

SetStyleTextboxSpecListOpt:
	/* empty*/
|	SetStyleTextboxSpecList

/*
set surface {implicit|explicit}
*/
SetSurfaceSpecOpt:
	/* empty */
|	"implicit"
|	"explicit"

/*
set table {"outfile" | $datablock}
*/
SetTableSpecOpt:
	/* empty */
|	Expression

/*
set timestamp {"<format>"} {top|bottom} {{no}rotate}
	{offset <xoff>{,<yoff>}} {font "<fontspec>"}
	{textcolor <colorspec>}
*/
SetTimestampSpecList:
	SetTimestampSpecListItem
|	SetTimestampSpecList SetTimestampSpecListItem

SetTimestampSpecListItem:
	SimpleExpression
|	"top"
|	"bottom"
|	"rotate"
|	"norotate"
|	"offset" ExpressionList
|	"font" Expression
|	"textcolor" ColorSpec

SetTimestampSpecListOpt:
	/* empty */ {}
|	SetTimestampSpecList

/*
set title 
	{"<title-text>"} {offset <offset>} {font "<font>{,<size>}"}
	{{textcolor | tc} {<colorspec> | default}} {{no}enhanced}
*/
SetTitleSpecOpt:
	/* empty */ {}
|	Expression
|	Expression SetTitleSpecList
|	SetTitleSpecList

SetTitleSpecList:
	SetTitleSpecListItem
|	SetTitleSpecList SetTitleSpecListItem

SetTitleSpecListItem:
	"offset" Position
|	"font" Expression
|	"textcolor" ColorSpec
|	"textcolor" "lt" ColorSpec
|	"tc" ColorSpec
|	"tc" "lt" ColorSpec
|	"textcolor" "default"
|	"tc" "default"
|	"enhanced"
|	"noenhanced"

/*
set terminal {<terminal-type> | push | pop}
*/
SetTerminalSpec:
	SetTerminalInner
|	"push"
|	"pop"

SetTerminalInner:
	"aifm" SetTerminalAifmSpecListOpt
|	"aqua" SetTerminalAquaSpecListOpt
|	"be" SetTerminalBeSpecListOpt
|	"cairolatex" SetTerminalCairolatexSpecListOpt
|	"canvas" SetTerminalCanvasSpecListOpt
|	"cgm" SetTerminalCgmSpecListOpt
|	"context" SetTerminalContextSpecListOpt
|	"corel" SetTerminalCorelSpecListOpt
|	"debug"
|	"dpu414" SetTerminalDpu414SpecListOpt
|	"dumb" SetTerminalDumbSpecListOpt
|	"dxf"
|	"dxy800a"
|	"eepic" SetTerminalEepicSpecListOpt
|	"emf" SetTerminalEmfSpecListOpt
|	"emtex" SetTerminalLatexSpecListOpt
|	"emxvesa" Expression
|	"emxvga"
|	"epslatex" SetTerminalEpslatexSpecListOpt
|	"epson_180dpi"
|	"epson_60dpi"
|	"excl"
|	"fig" SetTerminalFigSpecListOpt
|	"ggi" SetTerminalGgiSpecListOpt
|	"gif" SetTerminalGifSpecListOpt
|	"gpic"
|	"gpic" SimpleExpressionList
|	"grass"
|	"hp2623a"
|	"hp2648"
|	"hp500c"
|	"hpdj" ExpressionOpt
|	"hpgl" SetTerminalHpglSpecListOpt
|	"hpljii" ExpressionOpt
|	"hppj" SetTerminalHppjSpecOpt
|	"imagen" SetTerminalImagenSpecListOpt
|	"jpeg" SetTerminalJpegSpecListOpt
|	"kyo"
|	"latex" SetTerminalLatexSpecListOpt
|	"linux"
|	"lua" "tiks" SetTerminalLuatikzSpecListOpt
|	"mf"
|	"mif" SetTerminalMifSpecListOpt
|	"mp" SetTerminalMpSpecListOpt
|	"nec_cp6" SetTerminalNeccp6SpecListOpt
|	"next" SetTerminalNextSpecListOpt
|	"okidata"
|	"openstep" SetTerminalNextSpecListOpt
|	"pbm" SetTerminalPbmSpecListOpt
|	"pdf" SetTerminalPdfSpecListOpt
|	"pdfcairo" SetTerminalPdfcairoSpecListOpt
|	"pm" SetTerminalPmSpecListOpt
|	"png" SetTerminalPngSpecListOpt
|	"pngcairo" SetTerminalPngcairoSpecListOpt
|	"postscript" SetTerminalPostscriptSpecListOpt
|	"prescribe"
|	"pslatex" SetTerminalPstexSpecListOpt
|	"pstex" SetTerminalPstexSpecListOpt
|	"pstricks" SetTerminalPstricksSpecListOpt
|	"qms"
|	"qt" SetTerminalQtSpecListOpt
|	"regis" ExpressionOpt
|	"sun"
|	"svg" SetTerminalSvgSpecListOpt
|	"svga"
|	"svga" Expression
|	"tek40"
|	"tek410x"
|	"texdraw"
|	"tgif" SetTerminalTgifSpecListOpt
|	"tikz"
|	"tkcanvas" SetTerminalTkcanvasSpecListOpt
|	"tpic" Expression SimpleExpression SimpleExpression
|	"vgagl" SetTerminalVgaglSpecListOpt
|	"vgal"
|	"vws"
|	"windows" SetTerminalWindowsSpecListOpt
|	"wxt" SetTerminalWxtSpecListOpt
|	"x11" SetTerminalX11SpecListOpt

/*
set terminal aifm {color|monochrome} {"<fontname>"} {<fontsize>}
*/
SetTerminalAifmSpecList:
	SetTerminalAifmSpecListItem
|	SetTerminalAifmSpecList SetTerminalAifmSpecListItem

SetTerminalAifmSpecListItem:
	"color"
|	"monochrome"
|	SimpleExpression

SetTerminalAifmSpecListOpt:
	/* empty */ {}
|	SetTerminalAifmSpecList

/*
set terminal aqua {<n>} {title "<wintitle>"} {size <x> <y>}
	{font "<fontname>{,<fontsize>}"}
	{{no}enhanced} {solid|dashed} {dl <dashlength>}}
*/
SetTerminalAquaSpecList:
	SetTerminalAquaSpecListItem
|	SetTerminalAquaSpecList SetTerminalAquaSpecListItem

SetTerminalAquaSpecListItem:
	SimpleExpression
|	"title" Expression
|	"size"
|	"font" Expression
|	"enhanced"
|	"noenhanced"
|	"solid"
|	"dashed"
|	"dl" Expression

SetTerminalAquaSpecListOpt:
	/* empty */ {}
|	SetTerminalAquaSpecList

/*
set terminal be {reset} {<n>}
*/
SetTerminalBeSpecList:
	SetTerminalBeSpecListItem
|	SetTerminalBeSpecList SetTerminalBeSpecListItem

SetTerminalBeSpecListItem:
	"reset"
|	SimpleExpression

SetTerminalBeSpecListOpt:
	/* empty */ {}
|	SetTerminalBeSpecList

/*
set terminal cairolatex
	{eps | pdf}
	{standalone | input}
	{blacktext | colortext | colourtext}
	{header <header> | noheader}
	{mono|color}
	{{no}transparent} {{no}crop} {background <rgbcolor>}
	{font <font>} {fontscale <scale>}
	{linewidth <lw>} {rounded|butt|square} {dashlength <dl>}
	{size <XX>{unit},<YY>{unit}}
*/
SetTerminalCairolatexSpecList:
	SetTerminalCairolatexSpecListItem
|	SetTerminalCairolatexSpecList SetTerminalCairolatexSpecListItem

SetTerminalCairolatexSpecListItem:
	"eps"
|	"pdf"
|	"standalone"
|	"input"
|	"blacktext"
|	"colortext"
|	"colourtext"
|	"header" Expression
|	"noheader"
|	"mono"
|	"color"
|	"transparent"
|	"notransparent"
|	"crop"
|	"nocrop"
|	"background" Expression
|	"font" Expression
|	"fontscale" Expression
|	"linewidth" Expression
|	"rounded"
|	"butt"
|	"square"
|	"dashlength" Expression
|	"size" ExpressionUnitList

SetTerminalCairolatexSpecListOpt:
	/* empty */ {}
|	SetTerminalCairolatexSpecList

/*
set terminal cgm {color | monochrome} {solid | dashed} {{no}rotate}
	{<mode>} {width <plot_width>} {linewidth <line_width>}
	{font "<fontname>,<fontsize>"}
	{background <rgb_color>}
	{<color0> <color1> <color2> ...}
*/
SetTerminalCgmSpecList:
	SetTerminalCgmSpecListItem
|	SetTerminalCgmSpecList SetTerminalCgmSpecListItem

SetTerminalCgmSpecListItem:
	"color"
|	"monochrome"
|	"solid"
|	"dashed"
|	"rotate"
|	"norotate"
|	SimpleExpression
|	"width" Expression
|	"linewidth" Expression
|	"font" Expression
|	"background" Expression

SetTerminalCgmSpecListOpt:
	/* empty */ {}
|	SetTerminalCgmSpecList

/*
set term context {default}
	{defaultsize | size <scale> | size <xsize>{in|cm}, <ysize>{in|cm}}
	{input | standalone}
	{timestamp | notimestamp}
	{noheader | header "<header>"}
	{color | colour | monochrome}
	{rounded | mitered | beveled} {round | butt | squared}
	{dashed | solid} {dashlength | dl <dl>}
	{linewidth | lw <lw>}
	{fontscale <fontscale>}
	{mppoints | texpoints}
	{inlineimages | externalimages}
	{defaultfont | font "{<fontname>}{,<fontsize>}"}
*/
SetTerminalContextSpecList:
	SetTerminalContextSpecListItem
|	SetTerminalContextSpecList SetTerminalContextSpecListItem

SetTerminalContextSpecListItem:
	"default"
|	"defaultsize" Expression
|	"size" ExpressionUnitList
|	"input"
|	"standalone"
|	"timestamp"
|	"notimestamp"
|	"header" Expression
|	"noheader"
|	"color"
|	"colour"
|	"monochrome"
|	"rounded"
|	"mitered"
|	"beveled"
|	"round"
|	"butt"
|	"squared"
|	"dashed"
|	"solid"
|	"dashlength" Expression
|	"dl" Expression
|	"linewidth" Expression
|	"lw" Expression
|	"fontscale" Expression
|	"mppoints"
|	"texpoints"
|	"inlineimages"
|	"externalimages"
|	"defaultfont"
|	"font" Expression

SetTerminalContextSpecListOpt:
	/* empty */ {}
|	SetTerminalContextSpecList

/*
set terminal corel { default
	| {monochrome | color
	{"<font>" {<fontsize>
	{<xsize> <ysize> {<linewidth> }}}}}
*/
SetTerminalCorelSpecList:
	SetTerminalCorelSpecListItem
|	SetTerminalCorelSpecList SetTerminalCorelSpecListItem

SetTerminalCorelSpecListItem:
	"default"
|	"monochrome"
|	"color"
|	SimpleExpression

SetTerminalCorelSpecListOpt:
	/* empty */ {}
|	SetTerminalCorelSpecList

/*
set terminal dumb {size <xchars>,<ychars>} {[no]feed}
	{aspect <htic>{,<vtic>}}
	{[no]enhanced}
*/
SetTerminalDumbSpecList:
	SetTerminalDumbSpecListItem
|	SetTerminalDumbSpecList SetTerminalDumbSpecListItem

SetTerminalDumbSpecListItem:
	"size" ExpressionList
|	"feed"
|	"nofeed"
|	"aspect" ExpressionList
|	"enhanced"
|	"noenhanced"

SetTerminalDumbSpecListOpt:
	/* empty */ {}
|	SetTerminalDumbSpecList

/*
set terminal eepic {default} {color|dashed} {rotate} {size XX,YY}
	{small|tiny|<fontsize>}
*/
SetTerminalEepicSpecList:
	SetTerminalEepicSpecListItem
|	SetTerminalEepicSpecList SetTerminalEepicSpecListItem

SetTerminalEepicSpecListItem:
	"default"
|	"color"
|	"dashed"
|	"rotate"
|	"size" ExpressionList
|	"small"
|	"tiny"
|	SimpleExpression	

SetTerminalEepicSpecListOpt:
	/* empty */ {}
|	SetTerminalEepicSpecList

/*
set terminal emf {color | monochrome}
	{enhanced {noproportional}}
	{rounded | butt}
	{linewidth <LW>} {dashlength <DL>}
	{size XX,YY} {background <rgb_color>}
	{font "<fontname>{,<fontsize>}"}
	{fontscale <scale>}
*/
SetTerminalEmfSpecList:
	SetTerminalEmfSpecListItem
|	SetTerminalEmfSpecList SetTerminalEmfSpecListItem

SetTerminalEmfSpecListItem:
	"color"
|	"monochrome"
|	"enhanced"
|	"noproportional"
|	"rounded"
|	"butt"
|	"linewidth" Expression
|	"dashlength" Expression
|	"size" ExpressionList
|	"background" Expression
|	"font" Expression
|	"fontscale" Expression

SetTerminalEmfSpecListOpt:
	/* empty */ {}
|	SetTerminalEmfSpecList

/*
set terminal nec_cp6 {monochrome | colour | draft}
*/
SetTerminalNeccp6SpecList:
	SetTerminalNeccp6SpecListItem
|	SetTerminalNeccp6SpecList SetTerminalNeccp6SpecListItem

SetTerminalNeccp6SpecListItem:
	"monochrome"
|	"colour"
|	"draft"

SetTerminalNeccp6SpecListOpt:
	/* empty */ {}
|	SetTerminalNeccp6SpecList

/*
set terminal dpu414 {small | medium | large} {normal | draft}
*/
SetTerminalDpu414SpecList:
	SetTerminalDpu414SpecListItem
|	SetTerminalDpu414SpecList SetTerminalDpu414SpecListItem

SetTerminalDpu414SpecListItem:
	"small"
|	"medium"
|	"large"
|	"normal"
|	"draft"

SetTerminalDpu414SpecListOpt:
	/* empty */ {}
|	SetTerminalDpu414SpecList

/*
set terminal fig {monochrome | color}
	{landscape | portrait}
	{small | big | size <xsize> <ysize>}
	{metric | inches}
	{pointsmax <max_points>}
	{solid | dashed}
	{font "<fontname>{,<fontsize>}"}
	{textnormal | {textspecial texthidden textrigid}}
	{{thickness|linewidth} <units>}
	{depth <layer>}
	{version <number>}
*/
SetTerminalFigSpecList:
	SetTerminalFigSpecListItem
|	SetTerminalFigSpecList SetTerminalFigSpecListItem

SetTerminalFigSpecListItem:
	"monochrome"
|	"color"
|	"landscape"
|	"big"
|	"size" Expression SimpleExpression
|	"metric"
|	"inches"
|	"pointsmax" Expression
|	"solid"
|	"dashed"
|	"font" Expression
|	"textnormal"
|	"textspecial"
|	"texthidden"
|	"textrigid"
|	"thickness" Expression
|	"linewidth" Expression
|	"depth" Expression
|	"version" Expression

SetTerminalFigSpecListOpt:
	/* empty */ {}
|	SetTerminalFigSpecList

/*
set terminal ggi [acceleration <integer>] [[mode] {mode}]
*/
SetTerminalGgiSpecList:
	SetTerminalGgiSpecListItem
|	SetTerminalGgiSpecList SetTerminalGgiSpecListItem

SetTerminalGgiSpecListItem:
	"acceleration" Expression
|	"mode" Expression

SetTerminalGgiSpecListOpt:
	/* empty */ {}
|	SetTerminalGgiSpecList

/*
set terminal gif
	{{no}enhanced}
	{{no}transparent} {rounded|butt}
	{linewidth <lw>} {dashlength <dl>}
	{tiny | small | medium | large | giant}
	{font "<face> {,<pointsize>}"} {fontscale <scale>}
	{size <x>,<y>} {{no}crop}
	{animate {delay <d>} {loop <n>} {{no}optimize}}
	{background <rgb_color>}
*/
SetTerminalGifSpecList:
	SetTerminalGifSpecListItem
|	SetTerminalGifSpecList SetTerminalGifSpecListItem

SetTerminalGifSpecListItem:
	"enhanced"
|	"noenhanced"
|	"transparent"
|	"notransparent"
|	"rounded"
|	"butt"
|	"linewidth" Expression
|	"dashlength" Expression
|	"tiny"
|	"small"
|	"medium"
|	"large"
|	"giant"
|	"font" Expression
|	"fontscale" Expression
|	"size" ExpressionList
|	"crop"
|	"nocrop"
|	"animate" ExpressionOpt
|	"loop" Expression
|	"optimize"
|	"nooptimize"
|	"background" Expression

SetTerminalGifSpecListOpt:
	/* empty */ {}
|	SetTerminalGifSpecList

/*
set terminal hpgl {<number_of_pens>} {eject}
*/
SetTerminalHpglSpecList:
	SetTerminalHpglSpecListItem
|	SetTerminalHpglSpecList SetTerminalHpglSpecListItem

SetTerminalHpglSpecListItem:
	SimpleExpression
|	"eject"

SetTerminalHpglSpecListOpt:
	/* empty */ {}
|	SetTerminalHpglSpecList

/*
set terminal hppj {FNT5X9 | FNT9X17 | FNT13X25}
*/
SetTerminalHppjSpecOpt:
	/* empty */ {}
	"FNT5X9"
|	"FNT9X17"
|	"FNT13X25"

/*
set terminal imagen {<fontsize>} {portrait | landscape}
	{[<horiz>,<vert>]}
*/
SetTerminalImagenSpecList:
	SetTerminalImagenSpecListItem
|	SetTerminalImagenSpecList SetTerminalImagenSpecListItem

SetTerminalImagenSpecListItem:
	SimpleExpression
|	"portrait"
|	"landscape"
|	'[' ExpressionList ']'

SetTerminalImagenSpecListOpt:
	/* empty */ {}
|	SetTerminalImagenSpecList

/*
set terminal jpeg
	{{no}enhanced}
	{{no}interlace}
	{linewidth <lw>} {dashlength <dl>} {rounded|butt}
	{tiny | small | medium | large | giant}
	{font "<face> {,<pointsize>}"} {fontscale <scale>}
	{size <x>,<y>} {{no}crop}
	{background <rgb_color>}
*/
SetTerminalJpegSpecList:
	SetTerminalJpegSpecListItem
|	SetTerminalJpegSpecList SetTerminalJpegSpecListItem

SetTerminalJpegSpecListItem:
	"enhanced"
|	"noenhanced"
|	"linewidth" Expression
|	"dashlength" Expression
|	"rounded"
|	"butt"
|	"tiny"
|	"small"
|	"medium"
|	"large"
|	"giant"
|	"font" Expression
|	"fontscale" Expression
|	"size" ExpressionList
|	"crop"
|	"nocrop"
|	"background" Expression

SetTerminalJpegSpecListOpt:
	/* empty */ {}
|	SetTerminalJpegSpecList

/*
set terminal {latex | emtex} {default | {courier|roman} {<fontsize>}}
	{size <XX>{unit}, <YY>{unit}} {rotate | norotate}
*/
SetTerminalLatexSpecList:
	SetTerminalLatexSpecListItem
|	SetTerminalLatexSpecList SetTerminalLatexSpecListItem

SetTerminalLatexSpecListItem:
	"default"
|	"courier" ExpressionOpt
|	"roman" ExpressionOpt
|	"size" ExpressionUnitList
|	"rotate"
|	"norotate"

SetTerminalLatexSpecListOpt:
	/* empty */ {}
|	SetTerminalLatexSpecList

/*
set terminal lua tikz
	{latex | tex | context}
	{color | monochrome}
	{nooriginreset | originreset}
	{nogparrows | gparrows}
	{nogppoints | gppoints}
	{picenvironment | nopicenvironment}
	{noclip | clip}
	{notightboundingbox | tightboundingbox}
	{background "<colorpec>"}
	{size <x>{unit},<y>{unit}}
	{scale <x>,<y>}
	{plotsize <x>{unit},<y>{unit}}
	{charsize <x>{unit},<y>{unit}}
	{font "<fontdesc>"}
	{{fontscale | textscale} <scale>}
	{dashlength | dl <DL>}
	{linewidth | lw <LW>}
	{nofulldoc | nostandalone | fulldoc | standalone}
	{{preamble | header} "<preamble_string>"}
	{tikzplot <ltn>,...}
	{notikzarrows | tikzarrows}
	{rgbimages | cmykimages}
	{noexternalimages|externalimages}
	{bitmap | nobitmap}
	{providevars <var name>,...}
	{createstyle}
	{help}
*/
SetTerminalLuatikzSpecList:
	SetTerminalLuatikzSpecListItem
|	SetTerminalLuatikzSpecList SetTerminalLuatikzSpecListItem

SetTerminalLuatikzSpecListItem:
	"latex"
|	"tex"
|	"context"
|	"color"
|	"monochrome"
|	"originreset"
|	"nooriginreset"
|	"gparrows"
|	"nogparrows"
|	"gppoints"
|	"nogppoints"
|	"picenvironment"
|	"nopicenvironment"
|	"clip"
|	"noclip"
|	"tightboundingbox"
|	"notightboundingbox"
|	"background" Expression
|	"size" ExpressionUnitList
|	"scale" ExpressionList
|	"plotsize" ExpressionUnitList
|	"charsize" ExpressionUnitList
|	"font" Expression
|	"fontscale" Expression
|	"textscale" Expression
|	"dashlength" Expression
|	"dl" Expression
|	"linewidth" Expression
|	"lw" Expression
|	"nofulldoc"
|	"fulldoc"
|	"standalone"
|	"nostandalone"
|	"preamble" Expression
|	"header" Expression
|	"tikzplot" ExpressionList
|	"notikzarrows"
|	"tikzarrows"
|	"rgbimages"
|	"cmykimages"
|	"externalimages"
|	"noexternalimages"
|	"bitmap"
|	"nobitmap"
|	"providevars" IdentifierList
|	"createstyle"
|	"help"

SetTerminalLuatikzSpecListOpt:
	/* empty */ {}
|	SetTerminalLuatikzSpecList

/*
set terminal mif {color | colour | monochrome} {polyline | vectors}
	{help | ?}
*/
SetTerminalMifSpecList:
	SetTerminalMifSpecListItem
|	SetTerminalMifSpecList SetTerminalMifSpecListItem

SetTerminalMifSpecListItem:
	"color"
|	"colour"
|	"monochrome"
|	"polyline"
|	"vectors"
|	"help"
|	'?'

SetTerminalMifSpecListOpt:
	/* empty */ {}
|	SetTerminalMifSpecList

/*
set term mp {color | colour | monochrome}
	{solid | dashed}
	{notex | tex | latex}
	{magnification <magsize>}
	{psnfss | psnfss_version7 | nopsnfss}
	{prologues <value>}
	{a4paper}
	{amstex}
	{"<fontname> {,<fontsize>}"}
*/
SetTerminalMpSpecList:
	SetTerminalMpSpecListItem
|	SetTerminalMpSpecList SetTerminalMpSpecListItem

SetTerminalMpSpecListItem:
	"color"
|	"colour"
|	"monochrome"
|	"solid"
|	"dashed"
|	"notex"
|	"tex"
|	"latex"
|	"magnification" Expression
|	"psnfss"
|	"psnfss_version7"
|	"nopsnfss"
|	"prologues" Expression
|	"a4paper"
|	"amstex"
|	SimpleExpression

SetTerminalMpSpecListOpt:
	/* empty */ {}
|	SetTerminalMpSpecList

/*
set terminal next {<mode>} {<type> } {<color>} {<dashed>}
	{"<fontname>"} {<fontsize>} title {"<newtitle>"}
set terminal openstep {<mode>} {<type> } {<color>} {<dashed>}
	{"<fontname>"} {<fontsize>} title {"<newtitle>"}
*/
SetTerminalNextSpecList:
	SetTerminalNextSpecListItem
|	SetTerminalNextSpecList SetTerminalNextSpecListItem

SetTerminalNextSpecListItem:
	SimpleExpression
|	"default"
|	"new"
|	"old"
|	"color"
|	"monochrome"
|	"solid"
|	"dashed"
|	"title" Expression

SetTerminalNextSpecListOpt:
	/* empty */ {}
|	SetTerminalNextSpecList

/*
set terminal pbm {<fontsize>} {<mode>} {size <x>,<y>}
*/
SetTerminalPbmSpecList:
	SetTerminalPbmSpecListItem
|	SetTerminalPbmSpecList SetTerminalPbmSpecListItem

SetTerminalPbmSpecListItem:
	SimpleExpression
|	"size" ExpressionList

SetTerminalPbmSpecListOpt:
	/* empty */ {}
|	SetTerminalPbmSpecList

/*
set terminal pdf {monochrome|color|colour}
	{{no}enhanced}
	{fname "<font>"} {fsize <fontsize>}
	{font "<fontname>{,<fontsize>}"} {fontscale <scale>}
	{linewidth <lw>} {rounded|butt}
	{dl <dashlength>}}
	{size <XX>{unit},<YY>{unit}}
*/
SetTerminalPdfSpecList:
	SetTerminalPdfSpecListItem
|	SetTerminalPdfSpecList SetTerminalPdfSpecListItem

SetTerminalPdfSpecListItem:
	"monochrome"
|	"color"
|	"colour"
|	"enhanced"
|	"noenhanced"
|	"fname" Expression
|	"fsize" Expression
|	"font" Expression
|	"fontscale" Expression
|	"linewidth" Expression
|	"lw" Expression
|	"rounded"
|	"butt"
|	"dl" Expression
|	"size" ExpressionUnitList

SetTerminalPdfSpecListOpt:
	/* empty */ {}
|	SetTerminalPdfSpecList

/*
set term pdfcairo
	{{no}enhanced} {mono|color}
	{font <font>} {fontscale <scale>}
	{linewidth <lw>} {rounded|butt|square} {dashlength <dl>}
	{background <rgbcolor>}
	{size <XX>{unit},<YY>{unit}}
*/
SetTerminalPdfcairoSpecList:
	SetTerminalPdfcairoSpecListItem
|	SetTerminalPdfcairoSpecList SetTerminalPdfcairoSpecListItem

SetTerminalPdfcairoSpecListItem:
	"enhanced"
|	"noenhanced"
|	"mono"
|	"color"
|	"font" Expression
|	"fontscale" Expression
|	"linewidth" Expression
|	"rounded"
|	"butt"
|	"square"
|	"dashlength" Expression
|	"background" Expression
|	"size" ExpressionUnitList

SetTerminalPdfcairoSpecListOpt:
	/* empty */ {}
|	SetTerminalPdfcairoSpecList

/*
set terminal pm {server {n}} {persist} {widelines} {enhanced} {"title"}
*/
SetTerminalPmSpecList:
	SetTerminalPmSpecListItem
|	SetTerminalPmSpecList SetTerminalPmSpecListItem

SetTerminalPmSpecListItem:
	"server" ExpressionOpt
|	"persist"
|	"widelines"
|	"enhanced"
|	SimpleExpression

SetTerminalPmSpecListOpt:
	/* empty */ {}
|	SetTerminalPmSpecList

/*
set terminal png
	{{no}enhanced}
	{{no}transparent} {{no}interlace}
	{{no}truecolor} {rounded|butt}
	{linewidth <lw>} {dashlength <dl>}
	{tiny | small | medium | large | giant}
	{font "<face> {,<pointsize>}"} {fontscale <scale>}
	{size <x>,<y>} {{no}crop}
	{background <rgb_color>}
*/
SetTerminalPngSpecList:
	SetTerminalPngSpecListItem
|	SetTerminalPngSpecList SetTerminalPngSpecListItem

SetTerminalPngSpecListItem:
	"enhanced"
|	"noenhanced"
|	"transparent"
|	"notransparent"
|	"interlace"
|	"nointerlace"
|	"truecolor"
|	"notruecolor"
|	"rounded"
|	"butt"
|	"linewidth" Expression
|	"dashlength" Expression
|	"tiny"
|	"small"
|	"medium"
|	"large"
|	"giant"
|	"font" Expression
|	"fontscale" Expression
|	"size" ExpressionList
|	"crop"
|	"nocrop"
|	"background" Expression

SetTerminalPngSpecListOpt:
	/* empty */ {}
|	SetTerminalPngSpecList

/*
set term pngcairo
	{{no}enhanced} {mono|color}
	{{no}transparent} {{no}crop} {background <rgbcolor>
	{font <font>} {fontscale <scale>}
	{linewidth <lw>} {rounded|butt|square} {dashlength <dl>}
	{size <XX>{unit},<YY>{unit}}
*/
SetTerminalPngcairoSpecList:
	SetTerminalPngcairoSpecListItem
|	SetTerminalPngcairoSpecList SetTerminalPngcairoSpecListItem

SetTerminalPngcairoSpecListItem:
	"enhanced"
|	"noenhanced"
|	"mono"
|	"color"
|	"transparent"
|	"notransparent"
|	"crop"
|	"nocrop"
|	"background" Expression
|	"font" Expression
|	"fontscale" Expression
|	"linewidth" Expression
|	"rounded"
|	"butt"
|	"square"
|	"dashlength" Expression
|	"size" ExpressionUnitList

SetTerminalPngcairoSpecListOpt:
	/* empty */ {}
|	SetTerminalPngcairoSpecList

/*
set terminal [pslatex | pstex] {default}
set terminal [pslatex | pstex]
	{rotate | norotate}
	{oldstyle | newstyle}
	{auxfile | noauxfile}
	{level1 | leveldefault | level3}
	{color | colour | monochrome}
	{background <rgbcolor> | nobackground}
	{dashlength | dl <DL>}
	{linewidth | lw <LW>}
	{rounded | butt}
	{clip | noclip}
	{palfuncparam <samples>{,<maxdeviation>}}
	{size <XX>{unit},<YY>{unit}}
	{<font_size>}
*/
SetTerminalPstexSpecList:
	SetTerminalPstexSpecListItem
|	SetTerminalPstexSpecList SetTerminalPstexSpecListItem

SetTerminalPstexSpecListItem:
	"default"
|	"rotate"
|	"norotate"
|	"oldstyle"
|	"newstyle"
|	"auxfile"
|	"noauxfile"
|	"level1"
|	"leveldefault"
|	"level3"
|	"color"
|	"colour"
|	"monochrome"
|	"background" Expression
|	"nobackground"
|	"dashlength" Expression
|	"dl" Expression
|	"linewidth" Expression
|	"lw" Expression
|	"rounded"
|	"butt"
|	"clip"
|	"noclip"
|	"palfuncparam" ExpressionList
|	"size" ExpressionUnitList
|	SimpleExpression

SetTerminalPstexSpecListOpt:
	/* empty */ {}
|	SetTerminalPstexSpecList

/*
set terminal pstricks {hacktext | nohacktext} {unit | nounit}
*/
SetTerminalPstricksSpecList:
	SetTerminalPstricksSpecListItem
|	SetTerminalPstricksSpecList SetTerminalPstricksSpecListItem

SetTerminalPstricksSpecListItem:
	"hacktext"
|	"nohacktext"
|	"unit"
|	"nounit"

SetTerminalPstricksSpecListOpt:
	/* empty */ {}
|	SetTerminalPstricksSpecList

/*
set term qt {<n>}
	{size <width>,<height>}
	{position <x>,<y>}
	{title "title"}
	{font <font>} {{no}enhanced}
	{dashlength <dl>}
	{{no}persist} {{no}raise} {{no}ctrl}
	{close}
	{widget <id>}
*/
SetTerminalQtSpecList:
	SetTerminalQtSpecListItem
|	SetTerminalQtSpecList SetTerminalQtSpecListItem

SetTerminalQtSpecListItem:
	SimpleExpression
|	"size" ExpressionList
|	"position" ExpressionList
|	"title" Expression
|	"font" Expression
|	"enhanced"
|	"noenhanced"
|	"dashlength" Expression
|	"persist"
|	"nopersist"
|	"raise"
|	"noraise"
|	"ctrl"
|	"noctrl"
|	"close"
|	"widget" Expression

SetTerminalQtSpecListOpt:
	/* empty */ {}
|	SetTerminalQtSpecList

/*
set terminal svg {size <x>,<y> {|fixed|dynamic}}
	{{no}enhanced}
	{fname "<font>"} {fsize <fontsize>}
	{mouse} {standalone | jsdir <dirname>}
	{name <plotname>}
	{font "<fontname>{,<fontsize>}"}
	{fontfile <filename>}
	{rounded|butt|square} {solid|dashed} {linewidth <lw>}
	{background <rgb_color>}
*/
SetTerminalSvgSpecList:
	SetTerminalSvgSpecListItem
|	SetTerminalSvgSpecList SetTerminalSvgSpecListItem

SetTerminalSvgSpecListItem:
	"portrait"
|	"size" ExpressionList
|	"fixed"
|	"dynamic"
|	"enhanced"
|	"noenhanced"
|	"fname" Expression
|	"fsize" Expression
|	"mouse"
|	"standalone"
|	"jsdir" Expression
|	"name" Expression
|	"font" Expression
|	"fontfile" Expression
|	"rounded"
|	"butt"
|	"square"
|	"solid"
|	"dashed"
|	"linewidth" Expression
|	"background" Expression

SetTerminalSvgSpecListOpt:
	/* empty */ {}
|	SetTerminalSvgSpecList

/*
set terminal tgif {portrait | landscape | default} {<[x,y]>}
	{monochrome | color}
	{{linewidth | lw} <LW>}
	{solid | dashed}
	{font "<fontname>{,<fontsize>}"}
*/
SetTerminalTgifSpecList:
	SetTerminalTgifSpecListItem
|	SetTerminalTgifSpecList SetTerminalTgifSpecListItem

SetTerminalTgifSpecListItem:
	"portrait"
|	"landscape"
|	"default"
|	'[' ExpressionList ']'
|	"monochrome"
|	"color"
|	"linewdith" Expression
|	"lw" Expression
|	"solid"
|	"dashed"
|	"font" Expression
|	SimpleExpression

SetTerminalTgifSpecListOpt:
	/* empty */ {}
|	SetTerminalTgifSpecList

/*
set term tkcanvas {perltk} {interactive}
*/
SetTerminalTkcanvasSpecList:
	SetTerminalTkcanvasSpecListItem
|	SetTerminalTkcanvasSpecList SetTerminalTkcanvasSpecListItem

SetTerminalTkcanvasSpecListItem:
	"perltk"
|	"interactive"

SetTerminalTkcanvasSpecListOpt:
	/* empty */ {}
|	SetTerminalTkcanvasSpecList

/*
set terminal vgagl \
	background [red] [[green] [blue]] \
	[uniform | interpolate] \
	[mode]
*/
SetTerminalVgaglSpecList:
	SetTerminalVgaglSpecListItem
|	SetTerminalVgaglSpecList SetTerminalVgaglSpecListItem

SetTerminalVgaglSpecListItem:
	"background" ExpressionList
|	"uniform"
|	"interpolate"
|	SimpleExpression

SetTerminalVgaglSpecListOpt:
	/* empty */ {}
|	SetTerminalVgaglSpecList

/*
set terminal windows {<n>}
	{color | monochrome}
	{solid | dashed}
	{rounded | butt}
	{enhanced | noenhanced}
	{font <fontspec>}
	{fontscale <scale>}
	{linewdith <scale>}
	{background <rgb color>}
	{title "Plot Window Title"}
	{{size | wsize} <width>,<height>}
	{position <x>,<y>}
	{close}
*/
SetTerminalWindowsSpecList:
	SetTerminalWindowsSpecListItem
|	SetTerminalWindowsSpecList SetTerminalWindowsSpecListItem

SetTerminalWindowsSpecListItem:
	SimpleExpression
|	"color"
|	"monochrome"
|	"solid"
|	"dashed"
|	"rounded"
|	"butt"
|	"enhanced"
|	"noenhanced"
|	"font" Expression
|	"fontscale" Expression
|	"linewidth" Expression
|	"background" Expression
|	"title" Expression
|	"size" Expression ',' Expression
|	"wsize" Expression ',' Expression
|	"position" Expression ',' Expression
|	"close"

SetTerminalWindowsSpecListOpt:
	/* empty */ {}
|	SetTerminalWindowsSpecList

/*
set term wxt {<n>}
	{size <width>,<height>} {position <x>,<y>}
	{background <rgb_color>}
	{{no}enhanced}
	{font <font>} {fontscale <scale>}
	{title "title"}
	{linewidth <lw>}
	{dashlength <dl>}
	{{no}persist}
	{{no}raise}
	{{no}ctrl}
	{close}
*/
SetTerminalWxtSpecList:
	SetTerminalWxtSpecListItem
|	SetTerminalWxtSpecList SetTerminalWxtSpecListItem

SetTerminalWxtSpecListItem:
	SimpleExpression
|	"size" Expression ',' Expression
|	"position" Expression ',' Expression
|	"background" Expression
|	"enhanced"
|	"noenhanced"
|	"font" Expression
|	"fontscale" Expression
|	"title" Expression
|	"linewidth" Expression
|	"dashlength" Expression
|	"persist"
|	"nopersist"
|	"raise"
|	"noraise"
|	"ctrl"
|	"noctrl"
|	"close"

SetTerminalWxtSpecListOpt:
	/* empty */ {}
|	SetTerminalWxtSpecList

/*
set terminal x11 {<n> | window "<string>"}
	{title "<string>"}
	{{no}enhanced} {font <fontspec>}
	{linewidth LW}
	{{no}persist} {{no}raise} {{no}ctrlq}
	{{no}replotonresize}
	{close}
	{size XX,YY} {position XX,YY}
set terminal x11 {reset}
*/
SetTerminalX11SpecList:
	SetTerminalX11SpecListItem
|	SetTerminalX11SpecList SetTerminalX11SpecListItem

SetTerminalX11SpecListItem:
	SimpleExpression
|	"window" Expression
|	"enhanced"
|	"noenhanced"
|	"font" Expression
|	"linewidth" Expression
|	"persist"
|	"nopersist"
|	"raise"
|	"noraise"
|	"ctrlq"
|	"noctrlq"
|	"replotonresize"
|	"noreplotonresize"
|	"close"
|	"size" Expression ',' Expression
|	"position" Expression ',' Expression
|	"reset"

SetTerminalX11SpecListOpt:
	/* empty */ {}
|	SetTerminalX11SpecList

/*
set terminal canvas {size <xsize>, <ysize>} {background <rgb_color>}
	{font {<fontname>}{,<fontsize>}} | {fsize <fontsize>}
	{{no}enhanced} {linewidth <lw>}
	{rounded | butt | square}
	{dashlength <dl>}
	{standalone {mousing} | name ’<funcname>’}
	{jsdir ’URL/for/javascripts’}
	{title ’<some string>’}
*/
SetTerminalCanvasSpecList:
	SetTerminalCanvasSpecListItem
|	SetTerminalCanvasSpecList SetTerminalCanvasSpecListItem

SetTerminalCanvasSpecListItem:
	"size" Expression ',' Expression
|	"background" Expression
|	"fsize" Expression
|	"enhanced"
|	"noenhanced"
|	"linewidth" Expression
|	"lw" Expression
|	"rounded"
|	"butt"
|	"square"
|	"dashlength" Expression
|	"standalone"
|	"mousing"
|	"name" Expression
|	"jsdir" Expression
|	"title" Expression

SetTerminalCanvasSpecListOpt:
	/* empty */ {}
|	SetTerminalCanvasSpecList

/*
set terminal postscript {default}
set terminal postscript {landscape | portrait | eps}
	{enhanced | noenhanced}
	{defaultplex | simplex | duplex}
	{fontfile [add | delete] "<filename>"
	| nofontfiles} {{no}adobeglyphnames}
	{level1 | leveldefault | level3}
	{color | colour | monochrome}
	{background <rgbcolor> | nobackground}
	{dashlength | dl <DL>}
	{linewidth | lw <LW>}
	{rounded | butt}
	{clip | noclip}
	{palfuncparam <samples>{,<maxdeviation>}}
	{size <XX>{unit},<YY>{unit}}
	{blacktext | colortext | colourtext}
	{{font} "fontname{,fontsize}" {<fontsize>}}
	{fontscale <scale>}
*/
SetTerminalPostscriptSpecList:
	SetTerminalPostscriptSpecListItem
|	SetTerminalPostscriptSpecList SetTerminalPostscriptSpecListItem

SetTerminalPostscriptSpecListItem:
	"default"
|	"landscape"
|	"portrait"
|	"eps"
|	"enhanced"
|	"noenhanced"
|	"defaultplex"
|	"simplex"
|	"duplex"
|	"fontfile" Expression
|	"fontfile" "add" Expression
|	"fontfile" "delete" Expression
|	"nofontfiles"
|	"adobeglyphnames"
|	"noadobeglyphnames"
|	"level1"
|	"leveldefault"
|	"level3"
|	"color"
|	"colour"
|	"monochrome"
|	"background" Expression
|	"nobackground"
|	"dashlength" Expression
|	"dl" Expression
|	"linewidth" Expression
|	"lw" Expression
|	"rounded"
|	"butt"
|	"clip"
|	"noclip"
|	"palfuncparam" Expression
|	"palfuncparam" Expression ',' Expression
|	"size" ExpressionUnitList
|	"blacktext"
|	"colortext"
|	"colourtext"
|	"font" Expression %prec LESS_EXPR
|	"font" Expression SimpleExpression
|	SimpleExpression
|	"fontscale" Expression


SetTerminalPostscriptSpecListOpt:			
	/* empty */ {}
|	SetTerminalPostscriptSpecList

/*
set terminal epslatex
set terminal epslatex
	{default}
	{standalone | input}
	{oldstyle | newstyle}
	{level1 | leveldefault | level3}
	{color | colour | monochrome}
	{background <rgbcolor> | nobackground}
	{dashlength | dl <DL>}
	{linewidth | lw <LW>}
	{rounded | butt}
	{clip | noclip}
	{palfuncparam <samples>{,<maxdeviation>}}
	{size <XX>{unit},<YY>{unit}}
	{header <header> | noheader}
	{blacktext | colortext | colourtext}
	{{font} "fontname{,fontsize}" {<fontsize>}}
	{fontscale <scale>}
*/

SetTerminalEpslatexSpecList:
	SetTerminalEpslatexSpecListItem
|	SetTerminalEpslatexSpecList SetTerminalEpslatexSpecListItem

SetTerminalEpslatexSpecListItem:
	"default"
|	"standalone"
|	"input"
|	"oldstyle"
|	"newstyle"
|	"level1"
|	"leveldefault"
|	"level3"
|	"color"
|	"colour"
|	"monochrome"
|	"background" Expression
|	"nobackground"
|	"dashlength" Expression
|	"dl" Expression
|	"linewidth" Expression
|	"lw" Expression
|	"rounded"
|	"butt"
|	"clip"
|	"noclip"
|	"palfuncparam" Expression
|	"palfuncparam" Expression ',' Expression
|	"size" ExpressionUnitList
|	"header" Expression
|	"noheader"
|	"blacktext"
|	"colortext"
|	"colourtext"
|	SimpleExpression
|	"font" Expression
|	"fontscale" Expression

SetTerminalEpslatexSpecListOpt:
	/* empty */ {}
|	SetTerminalEpslatexSpecList


/*
set termoption {no}enhanced
set termoption font "<fontname>{,<fontsize>}"
set termoption fontscale <scale>
set termoption {solid|dashed}
set termoption {linewidth <lw>}{lw <lw>}
*/
SetTermoptionSpec:
	"enhanced"
|	"noenhanced"
|	"font" Expression
|	"fontscale" Expression
|	"solid"
|	"dash"
|	"dashed"
|	"linewidth" Expression
|	"lw" Expression

/*
set xtics 
	{axis | border}
	{{no}mirror}
	{in | out}
	{scale {default | <major> {,<minor>}}}
	{{no}rotate {by <ang>}} {offset <offset> | nooffset}
	{left | right | center | autojustify}
	{add}
	{ autofreq
		| <incr>
		| <start>, <incr> {,<end>}
		| ({"<label>"} <pos> {<level>} {,{"<label>"}}...) 
	}
	{format "formatstring"} {font "name{,<size>}"}
	{{no}enhanced}
	{ numeric | timedate | geographic }
	{ rangelimited }
	{ textcolor <colorspec> }

The same syntax applies to ytics, ztics, x2tics, y2tics and cbtics.
*/
SetXTicsSpecList:
	SetXTicsSpecListItem
|	SetXTicsSpecList SetXTicsSpecListItem

SetXTicsSpecListItem:
	NonParenthesizedExpression %prec LESS_EXPR
|	NonParenthesizedExpression ',' Expression
|	NonParenthesizedExpression ',' Expression ',' Expression
|	'(' TicsLabelList ')'
|	"axis"
|	"border"
|	"mirror"
|	"nomirror"
|	"in"
|	"out"
|	"scale" "default"
|	"scale" Expression %prec LESS_EXPR
|	"scale" Expression ',' Expression
|	"rotate"
|	"rotate" "by" Expression %prec LESS_EXPR
|	"norotate"
|	"norotate" "by" Expression %prec LESS_EXPR
|	"offset" Expression %prec LESS_EXPR
|	"offset" Expression ',' Expression
|	"nooffset"
|	"left"
|	"right"
|	"center"
|	"autojustify"
|	"add" %prec LESS_LPAREN
|	"add" '(' TicsLabelList ')'
|	"autofreq"
|	"format" Expression %prec LESS_EXPR
|	"font"	Expression %prec LESS_EXPR
|	"enhanced"
|	"noenhanced"
|	"numeric"
|	"timedate"
|	"geographic"
|	"rangelimited"
|	"textcolor" %prec LESS_EXPR
|	"tc" %prec LESS_EXPR
|	"textcolor" ColorSpec
|	"tc" ColorSpec
|	"linetype" ColorSpec
|	"lt" ColorSpec

SetXTicsSpecListOpt:
	/* empty */ {}
|	SetXTicsSpecList

/*
set view <rot_x>{,{<rot_z>}{,{<scale>}{,<scale_z>}}}
set view map {scale <scale>}
set view {no}equal {xy|xyz}
*/
//yy:example "set vi 1, 2, 3, 4"
SetViewSpec:
	ExpressionOptList
|	"map"
|	"map" "scale" Expression
|	"equal" "xx"
|	"equal" "xy"
|	"equal" "xyz"
|	"noequal" "xx"
|	"noequal" "xy"
|	"noequal" "xyz"

/*
set xyplane at <zvalue>
set xyplane relative <frac>
*/
SetXyplaneSpec:
	"at" Expression
|	"relative" Expression
|	Expression

/*
set xlabel 
	{"<label>"}
	{offset <offset>}
	{font "<font>{,<size>}"}
	{textcolor <colorspec>}
	{{no}enhanced}
	{rotate by <degrees> | rotate parallel | norotate}
The same syntax applies to x2label, ylabel, y2label, zlabel and cblabel.
*/
SetXLabelSpecOpt:
	/* empty */ {}
|	Expression
|	Expression SetXLabelSpecList
|	SetXLabelSpecList

SetXLabelSpecList:
	SetXLabelSpecListItem
|	SetXLabelSpecList SetXLabelSpecListItem

SetXLabelSpecListItem:
	"offset" Position
|	"font" Expression
|	"tc" ColorSpec
|	"tc" "lt" ColorSpec
|	"tc"
|	"textcolor" ColorSpec
|	"textcolor" "lt" ColorSpec
|	"textcolor"
|	"enhanced"
|	"noenhanced"
|	"rotate"
|	"rotate" "by" Expression
|	"rotate" "parallel"
|	"norotate"

/*
set {x|x2|y|y2|z}zeroaxis { {linestyle | ls <line_style>}
	| { linetype | lt <line_type>}
	{ linewidth | lw <line_width>}}
unset {x|x2|y|y2|z}zeroaxis
show {x|y|z}zeroaxis
*/
SetZeroaxisSpecList:
	LineStyleListItem
|	SetZeroaxisSpecList LineStyleListItem

SetZeroaxisSpecListOpt:
	/* empty */ {}
|	SetZeroaxisSpecList

Show:
	"show" ShowSpec

ShowSpec:
	"angles"
|	"arrow" ExpressionOpt
|	"auto"
|	"autoscale"
|	"bars"
|	"bind"
|	"bmargin"
|	"border"
|	"boxwidth"
|	"cbdata"
|	"cbdtics"
|	"cblabel"
|	"cbmtics"
|	"cbrange"
|	"cbtics"
|	"clabel"
|	"clip"
|	"cntrlabel"
|	"cntrp"
|	"cntrparam"
|	"color"
|	"colorbox"
|	"colornames"
|	"colorsequence"
|	"contour"
|	"dashtype"
|	"datafile" ShowDatafileSpecListOpt
|	"decimalsign"
|	"dgrid3d"
|	"dummy"
|	"encoding"
|	"fit"
|	"fontpath"
|	"format"
|	"grid"
|	"hidden3d"
|	"history"
|	"iso"
|	"isosamples"
|	"key"
|	"label" ExpressionOpt
|	"linetype"
|	"link"
|	"lmargin"
|	"loadpath"
|	"locale"
|	"log"
|	"logscale"
|	"mapping"
|	"margins"
|	"monochrome"
|	"mouse"
|	"mcbtics"
|	"multiplot"
|	"mx2tics"
|	"mxtics"
|	"my2tics"
|	"mytics"
|	"mztics"
|	"object"
|	"offsets"
|	"origin"
|	"output"
|	"palette"
|	"parametric"
|	"paxis"
|	"pm3d"
|	"pointintervalbox"
|	"pointsize"
|	"polar"
|	"print"
|	"psdir"
|	"raxis"
|	"rmargin"
|	"rrange"
|	"rtics"
|	"sam"
|	"sample"
|	"samples"
|	"size"
|	"style" "arrow"
|	"style" "boxplot"
|	"style" "circle"
|	"style" "ellipse"
|	"style" "fill"
|	"style" "histogram"
|	"style" "line"
|	"style" "rectangle"
|	"style" "textbox"
|	"surface"
|	"table"
|	"terminal"
|	"termoption"
|	"tics"
|	"ticslevel"
|	"time"
|	"timefmt"
|	"timestamp"
|	"title"
|	"tmargin"
|	"trange"
|	"urange"
|	"var"
|	"variable" IDENTIFIER
|	"variables"
|	"variables" "all"
|	"variables" IDENTIFIER
|	"vi"
|	"view"
|	"vrange"
|	"x2data"
|	"x2label"
|	"x2mtics"
|	"x2range"
|	"x2tics"
|	"x2zeroaxis"
|	"xdata"
|	"x2dtics"
|	"xdtics"
|	"xlabel"
|	"xmtics"
|	"xrange"
|	"xtics"
|	"xyplane"
|	"xzeroaxis"
|	"y2data"
|	"y2mtics"
|	"y2range"
|	"y2tics"
|	"y2zeroaxis"
|	"ydata"
|	"y2dtics"
|	"ydtics"
|	"ylabel"
|	"ymtics"
|	"yrange"
|	"ytics"
|	"yzeroaxis"
|	"zdata"
|	"zdtics"
|	"zero"
|	"zeroaxis"
|	"zlabel"
|	"zmtics"
|	"zrange"
|	"ztics"
|	"zzeroaxis"

ShowDatafileSpecList:
	ShowDatafileSpecListItem
|	ShowDatafileSpecList ShowDatafileSpecListItem

ShowDatafileSpecListItem:
	"missing"
|	"separator"
|	"commentschars"
|	"binary"
|	"datasizes"
|	"filetypes"

ShowDatafileSpecListOpt:
	/* empty */ {}
|	ShowDatafileSpecList

//yy:example "set tics ( ident_a ident_b != ident_c )"
SimpleExpression:
	SimpleExpression "!=" SimpleExpression
//yy:example "set tics ( ident_a ident_b && ident_c )"
|	SimpleExpression "&&" SimpleExpression
//yy:example "set tics ( ident_a ident_b ** ident_c )"
|	SimpleExpression "**" SimpleExpression
//yy:example "set tics ( ident_a ident_b << ident_c )"
|	SimpleExpression "<<" SimpleExpression
//yy:example "set tics ( ident_a ident_b <= ident_c )"
|	SimpleExpression "<=" SimpleExpression
//yy:example "set tics ( ident_a ident_b == ident_c )"
|	SimpleExpression "==" SimpleExpression
//yy:example "set tics ( ident_a ident_b >= ident_c )"
|	SimpleExpression ">=" SimpleExpression
//yy:example "set tics ( ident_a ident_b >> ident_c )"
|	SimpleExpression ">>" SimpleExpression
//yy:example "set tics ( ident_a ident_b eq ident_c )"
|	SimpleExpression "eq" SimpleExpression
//yy:example "set tics ( ident_a ident_b ne ident_c )"
|	SimpleExpression "ne" SimpleExpression
//yy:example "set tics ( ident_a ident_b || ident_c )"
|	SimpleExpression "||" SimpleExpression
//yy:example "set tics ( ident_a ident_b % ident_c )"
|	SimpleExpression '%' SimpleExpression
//yy:example "set tics ( ident_a ident_b & ident_c )"
|	SimpleExpression '&' SimpleExpression
//yy:example "set tics ( ident_a ident_b * ident_c )"
|	SimpleExpression '*' SimpleExpression
//yy:example "set tics ( ident_a ident_b + ident_c )"
|	SimpleExpression '+' SimpleExpression
//yy:example "set tics ( ident_a ident_b - ident_c )"
|	SimpleExpression '-' SimpleExpression
//yy:example "set tics ( ident_a ident_b . ident_c )"
|	SimpleExpression '.' SimpleExpression
//yy:example "set tics ( ident_a ident_b / ident_c )"
|	SimpleExpression '/' SimpleExpression
//yy:example "set tics ( ident_a ident_b < ident_c )"
|	SimpleExpression '<' SimpleExpression
//yy:example "set tics ( ident_a ident_b = ident_c )"
|	SimpleExpression '=' SimpleExpression
//yy:example "set tics ( ident_a ident_b > ident_c )"
|	SimpleExpression '>' SimpleExpression
//yy:example "set tics ( ident_a ident_b ? ident_c : ident_d )"
|	SimpleExpression '?' SimpleExpression ':' SimpleExpression
//yy:example "set tics ( ident_a ident_b ^ ident_c )"
|	SimpleExpression '^' SimpleExpression
//yy:example "set tics ( ident_a ident_b | ident_c )"
|	SimpleExpression '|' SimpleExpression
|	UnarySimpleExpression %prec LESS_FACTORIAL

SimpleExpressionList:
	SimpleExpression
|	SimpleExpressionList SimpleExpression

SimpleExpressionCommaList:
	SimpleExpression
|	SimpleExpressionCommaList ',' SimpleExpression

SliceArgument:
	/* empty */
|	'*'
|	Expression

Smoothing:
	"acsplines"
|	"bandwidth"
|	"bezier"
|	"cnormal"
|	"csplines"
|	"cumulative"
|	"frequency"
|	"kdensity"
|	"mcsplines"
|	"sbezier"
|	"unique"
|	"unwrap"

Splot:
	"splot" PlotElementList

Statement:
	/* empty */ {}
|	Bind
|	Clear
|	Eval
|	Fit
|	Import
|	Lower
|	Call
|	Cd
|	Do
|	Else
|	Exit
|	FunctionDefinition
|	If
|	Load
//yy:example "$data << EOD\n1 2 3\nEOD\n"
|	NamedDataBlock
|	Pause
|	Plot
|	Print
|	Replot
|	Reread
|	Reset
|	Set
|	Show
|	Splot
|	Stats
|	Test
|	Undefine
|	Unset
|	Update
|	VariableDefinition
|	While
|	error

//yy:example "foo=bar"
StatementList:
	Statement 
|	StatementList StatementSeparator Statement

StatementSeparator:
	';'
//yy:example "foo=bar\nbaz=qux"
|	'\n'

TicsLabelList:
	TicsLabelListItem
|	TicsLabelList ',' TicsLabelListItem

/*
({"<label>"} <pos> {<level>} {,{"<label>"}}...) 
*/
TicsLabelListItem:
	NonStringExpression
|	NonStringExpression SimpleExpression
|	NonStringExpression SimpleExpression SimpleExpression
|	STRING_LIT NonStringExpression		
|	STRING_LIT NonStringExpression SimpleExpression

UnaryExpression:
	PrimaryExpression %prec LESS_LBRACKET
|	'!' UnaryExpression
|	'+' UnaryExpression
|	'-' UnaryExpression
|	'~' UnaryExpression
|	UnaryExpression '!'

UnaryNonParenthesizedExpression:
	PrimaryNonParenthesizedExpression
|	'!' UnaryNonParenthesizedExpression
|	'+' UnaryNonParenthesizedExpression
|	'-' UnaryNonParenthesizedExpression
|	'~' UnaryNonParenthesizedExpression
|	UnaryNonParenthesizedExpression '!'

UnaryNonStringExpression:		
	PrimaryNonStringExpression		
|	'!' UnaryNonStringExpression		
|	'+' UnaryNonStringExpression		
|	'-' UnaryNonStringExpression		
|	'~' UnaryNonStringExpression		

UnarySimpleExpression:
	PrimaryExpression %prec LESS_LBRACKET
//yy:example "set tics ( 'foo' 1+!x 2+!y )"
|	'!' UnarySimpleExpression
|	'~' UnarySimpleExpression
|	UnarySimpleExpression '!'

/*
stats {<ranges>} ’filename’ {matrix | using N{:M}} {name ’prefix’} {{no}output}
*/
Stats:
	"stats" RangesOpt Expression StatsSpecListOpt

StatsSpecList:
	StatsSpecListItem
|	StatsSpecList StatsSpecListItem

StatsSpecListItem:
	"matrix"
|	"using" Expression
|	"using" Expression ':' Expression
|	"name" Expression
|	"output"
|	"nooutput"
|	"index" Expression
|	"prefix" Expression

StatsSpecListOpt:
	/* empty */ {}
|	StatsSpecList

Test:
	"test" "palette"
|	"test" "terminal"

Undefine:
	"undefine" UndefineList

UndefineList:
	UndefineListItem
|	UndefineList UndefineListItem

UndefineListItem:
	IDENTIFIER
|	IDENTIFIER '*'

Unit:
	"cm"
|	"mm"
|	"in"
|	"inch"
|	"pt"
|	"pc"
|	"bp"
|	"dd"
|	"cc"

UnitsOpt:
	/* empty */
|	"units" "xx"
|	"units" "xy"
|	"units" "yy"

Unset:
	"unset" IterationSpecifierOpt UnsetSpec

UnsetSpec:
	"angles"
|	"arrow" ExpressionOpt
|	"auto"
|	"autoscale"
|	"bars"
|	"bind"
|	"bmargin"
|	"border"
|	"boxwidth"
|	"cbdata"
|	"cbdtics"
|	"cblabel"
|	"cbmtics"
|	"cbrange"
|	"cbtics"
|	"clabel"
|	"clip"
|	"cntrlabel"
|	"cntrp"
|	"cntrparam"
|	"color"
|	"colorbox"
|	"colornames"
|	"colorsequence"
|	"contour"
|	"dashtype"
|	"datafile"
|	"decimalsign"
|	"dgrid3d"
|	"dummy"
|	"encoding"
|	"fit"
|	"fontpath"
|	"format"
|	"grid"
|	"hidden3d"
|	"history"
|	"iso"
|	"isosamples"
|	"key"
|	"label"
|	"label" Expression
|	"linetype"
|	"link"
|	"lmargin"
|	"loadpath"
|	"locale"
|	"log" UnsetLogscaleListOpt
|	"logscale" UnsetLogscaleListOpt
|	"mapping"
|	"margins"
|	"monochrome"
|	"mouse"
|	"mcbtics"
|	"multiplot"
|	"mx2tics"
|	"mxtics"
|	"my2tics"
|	"mytics"
|	"mztics"
|	"object"
|	"offsets"
|	"origin"
|	"output"
|	"palette"
|	"parametric"
|	"paxis"
|	"pm3d"
|	"pointintervalbox"
|	"pointsize"
|	"polar"
|	"print"
|	"psdir"
|	"raxis"
|	"rmargin"
|	"rrange"
|	"rtics"
|	"sam"
|	"sample"
|	"samples"
|	"size"
|	"style"
|	"surface"
|	"table"
|	"terminal"
|	"termoption"
|	"tics"
|	"ticslevel"
|	"time"
|	"timefmt"
|	"timestamp"
|	"title"
|	"tmargin"
|	"trange"
|	"urange"
|	"vi"
|	"view"
|	"vrange"
|	"x2data"
|	"x2label"
|	"x2mtics"
|	"x2range"
|	"x2tics"
|	"x2zeroaxis"
|	"xdata"
|	"x2dtics"
|	"xdtics"
|	"xlabel"
|	"xmtics"
|	"xrange"
|	"xtics"
|	"xyplane"
|	"xzeroaxis"
|	"y2data"
|	"y2mtics"
|	"y2range"
|	"y2tics"
|	"y2zeroaxis"
|	"ydata"
|	"y2dtics"
|	"ydtics"
|	"ylabel"
|	"ymtics"
|	"yrange"
|	"ytics"
|	"yzeroaxis"
|	"zdata"
|	"zdtics"
|	"zero"
|	"zeroaxis"
|	"zlabel"
|	"zmtics"
|	"zrange"
|	"ztics"
|	"zzeroaxis"

UnsetLogscaleList:
	SetLogscaleAxesListItem
|	UnsetLogscaleList SetLogscaleAxesListItem

UnsetLogscaleListOpt:
	/* empty */ {}
|	UnsetLogscaleList

/*
update <filename> {<filename>}
*/
Update:
	"update" Expression
|	"update" Expression SimpleExpression

UsingList:
	Expression
|	UsingList ':' Expression

VariableDefinition:
	IDENTIFIER '=' Expression
	{
		lx.scope.declare(lhs.Token, lhs)
	}

While:
	"while" '(' Expression ')' '{'
	{
		lx.pushScope()
	}
	StatementList '}'
	{
		lx.popScope(lhs.Token5)
	}
