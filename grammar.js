/**
 * @file Fe language grammar
 * @author Fe Language Team
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "fe",

  rules: {
    // TODO: add the actual grammar rules
    source_file: $ => "hello"
  }
});
