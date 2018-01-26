public class Linter.NamespaceRule : Rule {
    public bool end_of_namespace_comments {get; set; default = false;}
    public bool no_nested_namespaces {get; set; default = false;}

    public NamespaceRule() {
        base();
    }

    public override void setup(Config config) {
        base.setup(config);
        end_of_namespace_comments = config.get_bool_or(Config.CHECKS, "end_of_namespace_comments");
        no_nested_namespaces = config.get_bool_or(Config.CHECKS, "no_nested_namespaces");
    }

    public override void lint_tokens(TokenList tokens) {
        var namespaces = new Vala.ArrayList<NamespaceRef>();
        NamespaceRef? ns_ref = null;
        Token? token = null;
        int block_level = 0;
        while (tokens.next(out token)) {
            switch (token.type) {
            case Vala.TokenType.OPEN_BRACE:
                block_level++;
                break;
            case Vala.TokenType.CLOSE_BRACE:
                block_level--;
                if (ns_ref != null && ns_ref.block_level == block_level) {
                    ns_ref.close_begin = token.begin;
                    ns_ref.close_end = token.end;
                    lint_namespace(ns_ref);
                    ns_ref = null;
                    int size = namespaces.size;
                    if (size > 0) {
                        ns_ref = namespaces[size - 1];
                        namespaces.remove_at(size - 1);
                    }
                }
                break;
            case Vala.TokenType.NAMESPACE:
                string ns_name = "";
                Token? ns_token = token;
                while (ns_name != null && tokens.next(out token)) {
                    switch (token.type) {
                    case Vala.TokenType.IDENTIFIER:
                        ns_name += Utils.Buffer.substring(token.begin.pos, token.end.pos);
                        break;
                    case Vala.TokenType.DOT:
                        ns_name += ".";
                        break;
                    case Vala.TokenType.OPEN_BRACE:
                        if (ns_ref != null) {
                            namespaces.add(ns_ref);
                        }
                        ns_ref = new NamespaceRef(ns_ref, block_level, (owned) ns_name, ns_token.begin, token.end);
                        block_level++;
                        ns_name = null;
                        break;
                    default:
                        assert_not_reached();
                    }
                }
                break;
            }

        }
    }

    private void lint_namespace(NamespaceRef ns_ref) {
        if (no_nested_namespaces && ns_ref.parent != null) {
            error(ns_ref.open_begin, ns_ref.open_end,
                "Nesting of namespaces not allowed. Use `namespace %s {`.", ns_ref.full_name());
        }
        if (end_of_namespace_comments) {
            string? found = Utils.Buffer.substring_to_eol(ns_ref.close_end.pos);
            string pattern = "\\s+// namespace " + Regex.escape_string(ns_ref.name);
            if (found != null && !Regex.match_simple(pattern, found)) {
                string ns_end_text = " // namespace " + ns_ref.name;
                char* eol = Utils.Buffer.move_to_eol(ns_ref.close_end.pos);
                int column = ns_ref.close_end.column + (int) (eol - ns_ref.close_end.pos);
                error(
                    ns_ref.close_end,
                    Vala.SourceLocation(eol, ns_ref.close_end.line, column),
                    "Missing or malformed end of namespace comment: `}%s`",
                    ns_end_text);
                notice(ns_ref.open_begin, ns_ref.open_end, "The `%s` namespace begins here.", ns_ref.name);
                if (fix_errors) {
                    pattern = "\\s*//\\s*(namespace)?\\s*" + Regex.escape_string(ns_ref.name) + "\\s*";
                    if (Utils.String.is_whitespace(found) || Regex.match_simple(pattern, found)) {
                        fix(ns_ref.close_end.pos, eol, ns_end_text);
                    }
                }
            }
        }
    }

    private class NamespaceRef {
        public NamespaceRef? parent;
        public int block_level;
        public string name;
        public Vala.SourceLocation open_begin;
        public Vala.SourceLocation open_end;
        public Vala.SourceLocation close_begin;
        public Vala.SourceLocation close_end;

        public NamespaceRef(NamespaceRef? parent, int block_level, owned string name, Vala.SourceLocation open_begin, Vala.SourceLocation open_end) {
            this.parent = parent;
            this.block_level = block_level;
            this.name = name;
            this.open_begin = open_begin;
            this.open_end = open_end;
        }

        public string full_name() {
            return parent != null ? parent.full_name() + "." + name : name;
        }
    }
}
