;extends

;; 1) Inject SQL when the string itself starts with a SQL marker like `--sql`
(
  (string_literal (string_fragment) @injection.content)
  (#match? @injection.content "^(\r\n|\r|\n)*-{2,}( )*[sS][qQ][lL]")
  (#set! injection.language "sql")
)

;; 2) Inject SQL in the next string literal after a line comment `// sql`
(
  (line_comment) @comment
  .
  (variable_declarator
    value: (string_literal (string_fragment) @injection.content))
  (#match? @comment "^//+( )*[sS][qQ][lL]( )*")
  (#set! injection.language "sql")
)

;; 3) Inject SQL in the next string literal after a block comment `/* sql */`
(
  (block_comment) @comment
  .
  (variable_declarator
    value: (string_literal (string_fragment) @injection.content))
  (#match? @comment "(?s)^/\\*+( )*[sS][qQ][lL]( )*\\*/$")
  (#set! injection.language "sql")
)         
