;extends

            ; query
            ;; string sql injection
            ((string_fragment) @injection.content
                            (#match? @injection.content "^(\r\n|\r|\n)*-{2,}( )*[sS][qQ][lL]")
                            (#set! injection.language "sql"))
          
            ; query
            ;; comment sql injection
            ((comment) @comment .
              (lexical_declaration
                (variable_declarator
                  value: [
                    (string(string_fragment)@injection.content)
                    (template_string(string_fragment)@injection.content)
                  ]@injection.content)
              )
              (#match? @comment "^//+( )*[sS][qQ][lL]( )*")
              (#set! injection.language "sql")
            )
          