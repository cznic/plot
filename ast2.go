// Copyright 2016 The Plot Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package plot

import (
	"go/token"
)

// Node represents an AST node or a xc.Token.
type Node interface {
	Pos() token.Pos
}

type node token.Pos

func (n node) Pos() token.Pos { return token.Pos(n) }

// ----------------------------------------------------------------- Expression

func (n *Expression) isDash() bool {
	if n == nil {
		return false
	}

	if n.Case != 24 { // UnaryExpression
		return false
	}

	u := n.UnaryExpression
	if u.Case != 0 { // PrimaryExpression
		return false
	}

	p := u.PrimaryExpression
	if p.Case != 0 { // Operand
		return false
	}

	o := p.Operand
	if o.Case != 3 { // STRING_LIT
		return false
	}

	return o.Token.Val == idDash
}

// ------------------------------------------------------------- NamedDataBlock

func (n *NamedDataBlock) post(lx *lexer) {
	if n.Token.S()[0] != '$' {
		lx.err(n.Token, "data block names must start with '$'")
		return
	}

	if lx.lookahead.Rune != '\n' {
		lx.err(lx.lookahead, "extra characters after end-of-data delimiter")
		return
	}

	if data := lx.getInlineFiles(1, n.Token3.S()); len(data) == 1 {
		n.Data = data[0]
	}
}

// ----------------------------------------------------------------------- Plot

func (n *Plot) post(lx *lexer) {
	var nn int
	for l := n.PlotElementList; l != nil; l = l.PlotElementList {
		item := l.PlotElementListItem
		if !item.Expression.isDash() {
			continue
		}

		nn++
		opt := item.PlotElementModifiersListOpt
		if opt == nil {
			continue
		}

		for l := opt.PlotElementModifiersList; l != nil; l = l.PlotElementModifiersList {
			if i := l.PlotElementModifiersListItem; i.isBinary {
				lx.close(i, "cannot parse binary inline data")
				return
			}
		}
	}
	n.Data = lx.getInlineFiles(nn, []byte("e"))
}

// ----------------------------------------------------- SetPaletteSpecListItem

func (n *SetPaletteSpecListItem) post(lx *lexer) {
	if !n.Expression.isDash() {
		return
	}

	if data := lx.getInlineFiles(1, []byte("e")); len(data) == 1 {
		n.Data = data[0]
	}
}
