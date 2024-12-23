package tree_sitter_fe_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_fe "github.com/fe-lang/tree-sitter-fe/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_fe.Language())
	if language == nil {
		t.Errorf("Error loading Fe grammar")
	}
}
