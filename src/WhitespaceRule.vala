public class Linter.WhitespaceRule: Rule {
    public bool space_before_bracket {get; set; default = false;}
    public bool no_trailing_whitespace {get; set; default = false;}

    public WhitespaceRule() {
        base();
    }

    public override void setup(string param, string? value) {
        switch (param) {
        case "space_before_bracket":
            space_before_bracket = true;
            break;
        case "no_trailing_whitespace":
            no_trailing_whitespace = true;
            break;
        }
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
            }
        }
    }

    public override void visit_source_file(Vala.SourceFile file) {
        if (no_trailing_whitespace) {
            string? line;
            for (int i = 1; (line = file.get_source_line(i)) != null; i++) {
                char* pos = line;
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
        }
    }
}
