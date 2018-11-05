public class Linter.WhitespaceRule: Rule {
    public int space_indent {get; set; default = 0;}
    public bool space_before_bracket {get; set; default = false;}
    public bool space_after_comma {get; set; default = false;}
    public bool space_after_keyword {get; set; default = false;}
    public bool no_space_before_comma {get; set; default = false;}
    public bool no_trailing_whitespace {get; set; default = false;}
    public bool method_call_no_space {get; set; default = false;}

    public WhitespaceRule() {
        base();
    }

    public override void setup(Config config) {
        base.setup(config);
        space_after_comma = config.get_bool_or(Config.CHECKS, "space_after_comma");
        space_after_keyword = config.get_bool_or(Config.CHECKS, "space_after_keyword");
        no_space_before_comma = config.get_bool_or(Config.CHECKS, "no_space_before_comma");
        space_before_bracket = config.get_bool_or(Config.CHECKS, "space_before_bracket");
        no_trailing_whitespace = config.get_bool_or(Config.CHECKS, "no_trailing_whitespace");
        method_call_no_space = config.get_bool_or(Config.CHECKS, "method_call_no_space");
        space_indent = config.get_int_or(Config.CHECKS, "space_indent");
    }

    public override void lint_tokens(TokenList tokens) {
        if (space_indent > 0) {
            lint_space_indent(tokens);
            tokens.reset();
        }

        bool in_template = false;
        Token? token = null;
        while (tokens.next(out token)) {
            switch (token.type) {
            case Vala.TokenType.OPEN_TEMPLATE:
                in_template = true;
                break;
            case Vala.TokenType.CLOSE_TEMPLATE:
                in_template = false;
                break;
            case Vala.TokenType.OPEN_BRACE:
                if (space_before_bracket) {
                    Token? prev_token = null;
                    string? sep = null;
                    if (tokens.peek(-1, out prev_token)
                    && (sep = Utils.Buffer.substring(prev_token.end.pos, token.begin.pos)) != " ") {
                        bool is_ok = false;
                        switch (prev_token.type) {
                        case Vala.TokenType.OPEN_BRACE:
                        case Vala.TokenType.OPEN_PARENS:
                            is_ok = true;
                            break;
                        case Vala.TokenType.COMMA:
                        case Vala.TokenType.HASH:
                            is_ok = prev_token.end.pos != token.begin.pos;
                            break;
                        }
                        if (!is_ok) {
                            error(
                                prev_token.begin, token.end,
                                "There must be a single space between %s and `{`.", prev_token.type.to_string());
                            if (fix_errors && Utils.String.is_whitespace(sep)) {
                                fix(prev_token.end.pos, token.begin.pos, " ");
                            }
                        }
                    }
                }
                break;
            case Vala.TokenType.COMMA:
                if (!in_template) {
                    if (space_after_comma) {
                        lint_space_after_token(tokens, token, true);
                    }
                    if (no_space_before_comma) {
                        Token? prev_token = null;
                        if (tokens.peek(-1, out prev_token)) {
                            string? before_comma = Utils.Buffer.substring(prev_token.end.pos, token.begin.pos);
                            if (before_comma != null) {
                                error(
                                    prev_token.begin, token.end,
                                    "There must be no space between %s and `,`.", prev_token.type.to_string());
                                if (fix_errors && Utils.String.is_whitespace(before_comma)) {
                                    fix(prev_token.end.pos, token.begin.pos, null);
                                }
                            }
                        }
                    }
                }
                break;
            case Vala.TokenType.ABSTRACT:
            case Vala.TokenType.ASYNC:
            case Vala.TokenType.AS:
            case Vala.TokenType.CASE:
            case Vala.TokenType.CLASS:
            case Vala.TokenType.CONST:
            case Vala.TokenType.DELEGATE:
            case Vala.TokenType.DO:
            case Vala.TokenType.DYNAMIC:
            case Vala.TokenType.ENUM:
            case Vala.TokenType.ERRORDOMAIN:
            case Vala.TokenType.EXTERN:
            case Vala.TokenType.FINALLY:
            case Vala.TokenType.FOR:
            case Vala.TokenType.IF:
            case Vala.TokenType.IN:
            case Vala.TokenType.INTERFACE:
            case Vala.TokenType.INTERNAL:
            case Vala.TokenType.IS:
            case Vala.TokenType.LOCK:
            case Vala.TokenType.NEW:
            case Vala.TokenType.OUT:
            case Vala.TokenType.OVERRIDE:
            case Vala.TokenType.OWNED:
            case Vala.TokenType.PRIVATE:
            case Vala.TokenType.PROTECTED:
            case Vala.TokenType.PUBLIC:
            case Vala.TokenType.REF:
            case Vala.TokenType.RETURN:
            case Vala.TokenType.STATIC:
            case Vala.TokenType.STRUCT:
            case Vala.TokenType.UNOWNED:
            case Vala.TokenType.VAR:
            case Vala.TokenType.VIRTUAL:
            case Vala.TokenType.WHILE:
            case Vala.TokenType.WEAK:
            case Vala.TokenType.YIELD:
            case Vala.TokenType.NAMESPACE:
                if (space_after_keyword) {
                    lint_space_after_token(tokens, token);
                }
                break;
            }
        }
    }

    private void lint_space_indent(TokenList tokens) {
        int correct_indent_level = 0;
        int last_line = 0;
        Block? toplevel_namespace = null;
        Token? token = null;
        char* cursor = current_file.get_mapped_contents();
        var open_parens = new Vala.ArrayList<ParenRef>();
        while (tokens.next(out token)) {
            int line = token.begin.line;
            int indentation_shift = 0;
            if (toplevel_namespace != null) {
                indentation_shift--;
            }
            while (line - last_line > 1) {
                /* There were some lines without any token. */
                last_line++;
                cursor = Utils.Buffer.move_to_eol(cursor);
                if (cursor != null && *cursor == '\n') {
                    cursor++;
                    char* indent_begin = cursor;
                    int expected_level = correct_indent_level + indentation_shift;
                    char* indent_end = Utils.Buffer.skip_whitespace_stop_at_eol(indent_begin);
                    bool empty_line = Utils.Buffer.move_to_eol(indent_begin) - indent_begin == 0;
                    if (!empty_line) {
                        int extra_spaces = indent_end != null && *indent_end == '*' ? 1 : 0;  // multiline comments
                        lint_space_indent_line(last_line, expected_level, indent_begin, indent_end, extra_spaces);
                    }
                }
            }

            switch (token.type) {
            case Vala.TokenType.NAMESPACE:
                if (toplevel_namespace == null && token.begin.column == 1) {
                    toplevel_namespace = current_blocks.find(token.end.pos);
                }
                break;
            case Vala.TokenType.OPEN_PARENS:
            case Vala.TokenType.OPEN_BRACE:
                int i = open_parens.size - 1;
                if (i >= 0 && open_parens[i].line == line) {
                    open_parens[i].indents = false;
                } else {
                    correct_indent_level++;
                }
                open_parens.add(new ParenRef(token.type, line, true));
                if (token.type == Vala.TokenType.OPEN_BRACE
                && toplevel_namespace != null
                && toplevel_namespace.begin.pos == token.begin.pos) {
                    indentation_shift++;
                }
                break;
            case Vala.TokenType.CLOSE_PARENS:
            case Vala.TokenType.CLOSE_BRACE:
                if (token.type == Vala.TokenType.CLOSE_BRACE
                && toplevel_namespace != null
                && token.end.pos == toplevel_namespace.end.pos) {
                    indentation_shift++;
                    toplevel_namespace = null;
                }
                int i = open_parens.size - 1;
                if (i >= 0) {
                    ParenRef paren = open_parens.remove_at(i);
                    if (paren.indents) {
                        if (paren.line == line) {
                            if (--i >= 0) {
                                paren = open_parens[i];
                                if (paren.line == line) {
                                    paren.indents = true;
                                } else {
                                    correct_indent_level--;
                                }
                            } else {
                                correct_indent_level--;
                            }
                        } else {
                            correct_indent_level--;
                        }
                    }
                }
                break;
            }
            if (line != last_line) {
                switch (token.type) {
                case Vala.TokenType.CASE:
                case Vala.TokenType.DEFAULT:
                case Vala.TokenType.OPEN_BRACE:
                case Vala.TokenType.OP_AND:
                case Vala.TokenType.OP_OR:
                case Vala.TokenType.OPEN_PARENS:
                    indentation_shift--;
                    break;

                }
                char* indent_end = token.begin.pos;
                char* indent_begin = Utils.Buffer.skip_whitespace_backwards(indent_end, token.begin.column - 1);
                int expected_level = correct_indent_level + indentation_shift;
                lint_space_indent_line(line, expected_level, indent_begin, indent_end);
            }

            cursor = token.end.pos;
            last_line = token.end.line;  // It differs from `line` in multiline tokens, e.g. """literals"""
        }
    }

    private void lint_space_indent_line(
        int line, int expected_level, char* indent_begin, char* indent_end, int extra_spaces=0
    ) {
        unowned string? indent_begin_str = (string?) indent_begin;
        if (indent_begin_str != null && indent_begin_str.has_prefix("//~")) {
            return;
        }

        int indent_level = -1;
        string? indent = null;
        bool have_error = false;
        if (indent_end - indent_begin > 0) {
            if (Utils.Buffer.index_of_char(indent_begin, indent_end, '\t') != null) {
                have_error = true;
                error(
                    Vala.SourceLocation(indent_begin, line, 1),
                    Vala.SourceLocation(indent_end, line, Utils.Buffer.expanded_size(indent_begin, indent_end)),
                    "Tab for indentation is not allowed. Use %d spaces instead.", space_indent
                );
            }
            indent = Utils.Buffer.substring(indent_begin, indent_end).replace("\t", "    ");
            if ((indent.length - extra_spaces) % space_indent != 0) {
                indent = null;
                have_error = true;
                error(
                    Vala.SourceLocation(indent_begin, line, 1),
                    Vala.SourceLocation(indent_end, line, (int) (indent_end - indent_begin) + 1),
                    "Indentation is not a multiple of %d spaces.", space_indent);
            } else {
                indent_level = (indent.length - extra_spaces) / space_indent;
            }
        } else {
            indent = "";
            indent_level = 0;
        }

        if (indent_level >= 0 && indent_level != expected_level) {
            have_error = true;
            error(
                Vala.SourceLocation(indent_begin, line, 1),
                Vala.SourceLocation(indent_end, line, (int) (indent_end - indent_begin) + 1),
                "Incorrect identation level %d (%d expected).", indent_level, expected_level);
        }
        if (have_error && fix_errors) {
            string? indent_str = expected_level + extra_spaces > 0
            ? string.nfill(space_indent * expected_level + extra_spaces, ' ')
            : null;
            fix(indent_begin, indent_end, (owned) indent_str);
        }
    }

    private void lint_space_after_token(TokenList tokens, Token token, bool eol_ok=false) {
        if (token.begin.column > 1 && *(token.begin.pos - 1) == '.') {
            return;  // e.g. object.ref()
        }
        if (token.end.pos != null && *(token.end.pos) == ';') {
            return;  // e.g. yield;
        }
        char* pos = Utils.Buffer.skip_whitespace_stop_at_eol(token.end.pos);
        string? sep = Utils.Buffer.substring(token.end.pos, pos);
        bool doesnt_have_space = sep != " ";
        bool isnt_at_eol = pos != null && *pos != '\n';
        if (doesnt_have_space && (!eol_ok || isnt_at_eol)) {
            bool is_ok = false;
            // (owned) cast
            is_ok |= token.type == Vala.TokenType.OWNED && *(token.begin.pos - 1) == '(' && *(token.end.pos) == ')';
            is_ok |= token.type == Vala.TokenType.RETURN && *(token.end.pos) == ';';
            if (!is_ok) {
                Vala.SourceLocation location = {pos, token.end.line, token.end.column + (int)(pos - token.end.pos)};
                Token? next_token = null;
                if (tokens.peek(1, out next_token)) {
                    error(
                        token.end, location,
                        "There must be a single space between %s and %s.",
                        token.type.to_string(), next_token.type.to_string());
                } else {
                    error(
                        token.end, location,
                        "There must be a single space after %s.", token.type.to_string());
                }
                if (fix_errors) {
                    fix(token.end.pos, pos, " ");
                }
            }
        }
    }

    public override void lint_source_file(Vala.SourceFile file) {
        string? line;
        for (int i = 1; (line = file.get_source_line(i)) != null; i++) {
            char* pos = line;
            if (no_trailing_whitespace) {
                char* start;
                char* end;
                if (Utils.Buffer.has_trailing_whitespace(pos, out start, out end)) {
                    var col1 = (int) (start - pos + 1);
                    int col2 = col1 + Utils.Buffer.expanded_size(start, end);
                    error(
                        Vala.SourceLocation(start, i, col1),
                        Vala.SourceLocation(end, i, col2),
                        "Trailing whitespace not allowed.");

                    if (fix_errors) {
                        fix_line(i, pos, start, end, null);
                    }
                }
            }
        }
    }

    public override void lint_method_call (Vala.MethodCall expr) {
        if (method_call_no_space && expr.call != null) {
            Vala.SourceReference source_ref = expr.call.source_reference;
            char* paren = Utils.Buffer.index_of_char(source_ref.end.pos, null, '(');
            char* whitespace = Utils.Buffer.skip_whitespace_backwards(paren);
            if (paren - whitespace > 0) {
                error(
                    expr.source_reference.begin, expr.source_reference.end,
                    "No whitespace in method call allowed.");
                if (fix_errors) {
                    fix(whitespace, paren, null);
                }
            }
        }
    }

    private class ParenRef {
        public Vala.TokenType type;
        public int line;
        public bool indents;

        public ParenRef(Vala.TokenType type, int line, bool indents) {
            this.type = type;
            this.line = line;
            this.indents = indents;
        }
    }
}
