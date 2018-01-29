public class Linter.IfElseRule : Rule {
    public bool cuddled_else {get; set; default = false;}
    public bool cuddled_catch {get; set; default = false;}
    public bool if_else_blocks {get; set; default = false;}
    public bool if_else_no_blocks_same_line {get; set; default = false;}

    public IfElseRule() {
        base();
    }

    public override void setup(Config config) {
        base.setup(config);
        cuddled_else = config.get_bool_or(Config.CHECKS, "cuddled_else");
        cuddled_catch = config.get_bool_or(Config.CHECKS, "cuddled_catch");
        if_else_blocks = config.get_bool_or(Config.CHECKS, "if_else_blocks");
        if_else_no_blocks_same_line = config.get_bool_or(Config.CHECKS, "if_else_no_blocks_same_line");
    }

    public override void lint_tokens(TokenList tokens) {
        if (cuddled_else || cuddled_catch) {
            Token? prev_token = null;
            Token? token = null;
            while (tokens.next(out token)) {
                if (prev_token != null && prev_token.type == Vala.TokenType.CLOSE_BRACE) {
                    if (cuddled_catch && token.type == Vala.TokenType.CATCH
                    || cuddled_else && token.type == Vala.TokenType.ELSE) {
                        string sep = Utils.Buffer.substring(prev_token.end.pos, token.begin.pos);
                        if (sep != " ") {
                            error(
                                prev_token.end, token.begin,
                                "There must be a single space between %s and %s.",
                                prev_token.type.to_string(), token.type.to_string());
                            if (fix_errors && Utils.String.is_whitespace(sep)) {
                                fix(prev_token.end.pos, token.begin.pos, " ");
                            }
                        }
                    }
                    break;
                }
                prev_token = token;
            }
        }
    }

    public override void lint_if_statement (Vala.IfStatement stmt) {
        if (if_else_blocks) {
            unowned Vala.Block true_stmt = stmt.true_statement;
            unowned Vala.Block false_stmt = stmt.false_statement;
            if (true_stmt != null) {
                bool same_line = stmt.source_reference.end.line == true_stmt.source_reference.begin.line;
                if (if_else_no_blocks_same_line && same_line) return;
                char* block = Utils.Buffer.index_of_char(
                    stmt.source_reference.end.pos, true_stmt.source_reference.begin.pos + 1, '{');
                if (block == null) {
                    error(
                        stmt.source_reference.end, true_stmt.source_reference.begin,
                        "There must be `{` after if keyword.");
                    if (fix_errors) {
                        char* begin_pos = true_stmt.source_reference.begin.pos;
                        char* end_pos = Utils.CodeNode.find_end_of_stm(true_stmt.source_reference.end.pos, true_stmt);
                        fix(begin_pos, begin_pos, "{\n");
                        fix(end_pos, end_pos, "\n}");
                    }
                }
            }
            if (false_stmt != null && *(false_stmt.source_reference.begin.pos) != '{') {
                Vala.List<Vala.Statement> statements = false_stmt.get_statements();
                if (!(statements[0] is Vala.IfStatement)) {
                    error(
                        false_stmt.source_reference.begin, false_stmt.source_reference.begin,
                        "There must be `{` after else keyword.");
                    if (fix_errors) {
                        char* begin_pos = false_stmt.source_reference.begin.pos;
                        char* end_pos = Utils.CodeNode.find_end_of_stm(false_stmt.source_reference.end.pos, false_stmt);
                        fix(begin_pos, begin_pos, "{\n");
                        fix(end_pos, end_pos, "\n}");
                    }
                }
            }
        }
    }
}
