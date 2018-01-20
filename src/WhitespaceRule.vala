public class Linter.WhitespaceRule: Rule {
    public int space_indent {get; set; default = 0;}
    public bool space_before_bracket {get; set; default = false;}
    public bool space_after_comma {get; set; default = false;}
    public bool no_space_before_comma {get; set; default = false;}
    public bool no_trailing_whitespace {get; set; default = false;}

    public WhitespaceRule() {
        base();
    }

    public override void setup(Config config) {
        space_after_comma = config.get_bool_or(Config.CHECKS, "space_after_comma");
        no_space_before_comma = config.get_bool_or(Config.CHECKS, "no_space_before_comma");
        space_before_bracket = config.get_bool_or(Config.CHECKS, "space_before_bracket");
        no_trailing_whitespace = config.get_bool_or(Config.CHECKS, "no_trailing_whitespace");
        space_indent = config.get_int_or(Config.CHECKS, "space_indent");
    }

    public override void visit_tokens(TokenList tokens) {
        Token? token = null;
        while (tokens.next(out token)) {
            switch (token.type) {
            case Vala.TokenType.OPEN_BRACE:
                if (space_before_bracket) {
                    Token? prev_token = null;
                    if (tokens.peek(-1, out prev_token)
                    && prev_token.type != Vala.TokenType.OPEN_BRACE
                    && Utils.Buffer.substring(prev_token.end.pos, token.begin.pos) != " ") {
                        error(
                            prev_token.begin, token.end,
                            "There must be a single space between %s and `{`.", prev_token.type.to_string());
                    }
                }
                break;
            case Vala.TokenType.COMMA:
                if (space_after_comma) {
                    var pos = Utils.Buffer.skip_whitespace_stop_at_eol(token.end.pos);
                    var sep = Utils.Buffer.substring(token.end.pos, pos);
                    bool doesnt_have_space = sep != " ";
                    bool isnt_at_eol = sep == null && pos != null && *pos != '\n';
                    if (doesnt_have_space && isnt_at_eol) {
                        error(
                            token.end,
                            Vala.SourceLocation(pos, token.end.line, token.end.column + (int)(pos - token.end.pos)),
                            "There must be a single space after a comma but `%s` found.", sep);
                    }
                }
                if (no_space_before_comma) {
                    Token? prev_token = null;
                    if (tokens.peek(-1, out prev_token)
                    && Utils.Buffer.substring(prev_token.end.pos, token.begin.pos) != null) {
                        error(
                            prev_token.begin, token.end,
                            "There must be no space between %s and `,`.", prev_token.type.to_string());
                    }
                }
                break;
            }
        }
    }

    public override void visit_source_file(Vala.SourceFile file) {
        string? line;
        for (int i = 1; (line = file.get_source_line(i)) != null; i++) {
            char* pos = line;
            if (no_trailing_whitespace) {
                char* start;
                char* end;
                if (Utils.Buffer.has_trailing_whitespace(pos, out start, out end)) {
                    var col1 = (int) (start - pos + 1);
                    var col2 = col1 + Utils.Buffer.expanded_size(start, end);
                    error(
                        Vala.SourceLocation(start, i, col1),
                        Vala.SourceLocation(end, i, col2),
                        "Trailing whitespace not allowed.");
                }
            }
            if (space_indent > 0) {
                char* end = Utils.Buffer.skip_whitespace_stop_at_eol(pos);
                if (end != null) {
                    bool asterisk = end != null && *end == '*'; // Multi-line comments/* */
                    string indent = Utils.Buffer.substring(pos, end);
                    if (indent != null) {
                        if (Utils.Buffer.index_of_char((char*) indent, '\t') != null) {
                            error(
                                Vala.SourceLocation(pos, i, 0),
                                Vala.SourceLocation(end, i, Utils.Buffer.expanded_size(pos, end)),
                                "Tab for indentation is not allowed. Use %d spaces instead.", space_indent);
                        } else if (indent.length % space_indent != (asterisk ? 1 : 0)) {
                            error(
                                Vala.SourceLocation(pos, i, 0),
                                Vala.SourceLocation(end, i, Utils.Buffer.expanded_size(pos, end)),
                                "Indentation is not a multiple of %d spaces.", space_indent);
                        }
                    }
                }
            }
        }
    }
}
