/**
 * @file Fe language grammar
 * @author Fe Language Team
 * @license MIT
 */

module.exports = grammar({
  name: "fe",

  extras: ($) => [/\s+/, $.comment],

  word: ($) => $.identifier,

  rules: {
    source_file: ($) => repeat($._definition),

    _definition: ($) =>
      choice(
        $.module_def,
        $.function_def,
        $.struct_def,
        $.const_def,
        $.type_def,
      ),

    // Comments
    comment: ($) =>
      token(
        choice(
          seq("//", /.*/), // Line comment
          seq("/*", /[^*]*\*+([^/*][^*]*\*+)*/, "/"), // Block comment
        ),
      ),

    // Identifiers and paths
    identifier: ($) => /[_a-zA-Z][_a-zA-Z0-9]*/,

    path: ($) => sep1($.identifier, "::"),

    // Modules
    module_def: ($) =>
      seq("mod", field("name", $.identifier), "{", repeat($._definition), "}"),
    // Traits and Impls
    trait_def: ($) =>
      seq(
        optional("pub"),
        "trait",
        field("name", $.identifier),
        optional($.type_params),
        "{",
        repeat($.function_def),
        "}",
      ),

    impl_def: ($) =>
      seq(
        "impl",
        field("type", $._type),
        optional(seq("for", field("trait", $._type))),
        "{",
        repeat($.function_def),
        "}",
      ),

    // Match expressions
    match_expr: ($) =>
      seq(
        "match",
        field("value", $._expression),
        "{",
        repeat($.match_arm),
        "}",
      ),

    match_arm: ($) =>
      seq(
        field("pattern", $._pattern),
        "=>",
        field("value", $._expression),
        optional(";"),
      ),

    _pattern: ($) =>
      choice(
        $.identifier,
        $.literal,
        "_",
        seq($.path, "(", optional(sep1($._pattern, ",")), ")"),
      ),

    // Functions
    function_def: ($) =>
      seq(
        optional("pub"),
        "fn",
        field("name", $.identifier),
        optional($.type_params),
        "(",
        optional($.params),
        ")",
        optional(seq("->", field("return_type", $._type))),
        $.block,
      ),

    type_params: ($) => seq("<", sep1($._type_param, ","), ">"),

    _type_param: ($) => $.identifier,

    params: ($) => sep1($.param, ","),

    param: ($) => seq(field("name", $.identifier), ":", field("type", $._type)),

    // Types
    _type: ($) =>
      choice($.path, $.reference_type, $.primitive_type, $.tuple_type),

    primitive_type: ($) => choice("bool", "u8", "u64", "u128", "address"),

    reference_type: ($) => seq("&", optional("mut"), $._type),

    tuple_type: ($) =>
      seq("(", optional(seq($._type, repeat(seq(",", $._type)))), ")"),

    // Structs
    struct_def: ($) =>
      seq(
        optional("pub"),
        "struct",
        field("name", $.identifier),
        optional($.type_params),
        choice(
          $.struct_fields,
          ";", // Unit struct
        ),
      ),

    struct_fields: ($) => seq("{", optional(sep1($.struct_field, ",")), "}"),

    struct_field: ($) =>
      seq(
        optional("pub"),
        field("name", $.identifier),
        ":",
        field("type", $._type),
      ),

    // Constants
    const_def: ($) =>
      seq(
        optional("pub"),
        "const",
        field("name", $.identifier),
        ":",
        field("type", $._type),
        "=",
        $._expression,
        ";",
      ),

    // Type aliases
    type_def: ($) =>
      seq(
        optional("pub"),
        "type",
        field("name", $.identifier),
        optional($.type_params),
        "=",
        field("type", $._type),
        ";",
      ),

    // Expressions
    _expression: ($) => choice($.literal, $.path, $.block_expr),

    literal: ($) =>
      choice($.number_literal, $.boolean_literal, $.string_literal),

    number_literal: ($) => {
      const hex = /0x[a-fA-F0-9]+/;
      const dec = /[0-9]+/;
      const suffix = /(u8|u64|u128)?/;
      return token(choice(seq(hex, suffix), seq(dec, suffix)));
    },

    boolean_literal: ($) => choice("true", "false"),

    string_literal: ($) => seq('"', repeat(choice(/[^"\\]+/, /\\./)), '"'),

    // Blocks
    block: ($) => $.block_expr,

    block_expr: ($) =>
      seq("{", repeat($._statement), optional($._expression), "}"),

    _statement: ($) => choice($.let_statement, seq($._expression, ";")),

    let_statement: ($) =>
      seq(
        "let",
        optional("mut"),
        field("name", $.identifier),
        optional(seq(":", field("type", $._type))),
        optional(seq("=", field("value", $._expression))),
        ";",
      ),
  },
});

function sep1(rule, separator) {
  return seq(rule, repeat(seq(separator, rule)));
}
