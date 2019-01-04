WIP Vala Linter
===============

This is a work-in-progress Vala language linter for [Nuvola Apps project](https://github.com/tiliado/nuvolaruntime).

Installation
------------

Dependencies:

  - GNU Make
  - Vala 0.42.x
  - GLib/GIO
  - GNU diff

Build:

    make all
    make DESTDIR=... PREFIX=... install


Usage
-----

1. Create valalint configuration file `.valalint.conf`:

```
[Checks]
end_of_namespace_comments = true
space_before_bracket = true
no_nested_namespaces = true
no_trailing_whitespace = true
space_after_comma = true
no_space_before_comma = true
space_indent = 4
space_after_keyword = true
method_call_no_space = true
var_keyword_object_creation = true
var_keyword_array_creation = true
var_keyword_cast = true
if_else_blocks = true
if_else_no_blocks_same_line = true
cuddled_else = true
cuddled_catch = true
loop_blocks = true
```

2. See `valalint --help`.

Copyright
---------

  - Copyright 2018 Jiří Janoušek
  - Copyright 2008-2012 Jürg Billeter (Scanner.vala)
  - License: [GNU LGPL 2.1+](./LICENSE)
