; Fe test module
(
    (mod_definition
        name: (_) @run
        (#eq? @run "tests")
    )
    (#set! tag fe-mod-test)
)

; Fe test function (with #[test] attribute)
(
    (function_definition
        (attribute_list
            (attribute
                name: (identifier) @_attribute
                (#match? @_attribute "test")))
        name: (_) @run
        body: _
    )
    (#set! tag fe-test)
)
