public class Linter.IfElseRule : Rule {
    public bool cuddled_else {get; set; default = false;}
    public bool cuddled_catch {get; set; default = false;}
    public bool if_else_blocks {get; set; default = false;}
    public bool loop_blocks {get; set; default = false;}
    public bool if_else_no_blocks_same_line {get; set; default = false;}

    public IfElseRule() {
        base();
    }

    public override void setup(Config config) {
        base.setup(config);
        cuddled_else = config.get_bool_or(Config.CHECKS, "cuddled_else");
        cuddled_catch = config.get_bool_or(Config.CHECKS, "cuddled_catch");
        loop_blocks = config.get_bool_or(Config.CHECKS, "loop_blocks");
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
                }
                prev_token = token;
            }
        }
    }

    public override void lint_if_statement (Vala.IfStatement stmt) {
        if (if_else_blocks) {
            unowned Vala.Block true_stmt = stmt.true_statement;
            if (true_stmt != null) {
                bool same_line = stmt.source_reference.end.line == true_stmt.source_reference.begin.line;
                if (!if_else_no_blocks_same_line || !same_line) {
                    lint_block_required_after_statement("if", stmt.true_statement, null);
                }
            }
            lint_block_required_after_statement("else", stmt.false_statement, {typeof(Vala.IfStatement)});
        }
    }

    public override void lint_for_statement (Vala.ForStatement stmt) {
        if (loop_blocks) {
            lint_block_required_after_statement("for", stmt.body, null);
        }
    }

    public override void lint_foreach_statement (Vala.ForeachStatement stmt) {
        if (loop_blocks) {
            lint_block_required_after_statement("foreach", stmt.body, null);
        }
    }

    public override void lint_while_statement (Vala.WhileStatement stmt) {
        if (loop_blocks) {
            lint_block_required_after_statement("while", stmt.body, null);
        }
    }

    private void lint_block_required_after_statement(string keyword, Vala.Block? block, Type[]? allowed_stmts=null) {
        if (block != null && *(block.source_reference.begin.pos) != '{') {
            Vala.List<Vala.Statement> stmts = block.get_statements();
            if (allowed_stmts == null || stmts.size == 0 || !(Type.from_instance(stmts[0]) in allowed_stmts)) {
                error(
                    block.source_reference.begin, block.source_reference.begin,
                    "There must be `{` after `%s` keyword.", keyword);
                if (fix_errors) {
                    char* begin_pos = block.source_reference.begin.pos;
                    char* end_pos = Utils.CodeNode.find_end_of_stm(block.source_reference.end.pos, block);
                    fix(begin_pos, begin_pos, "{\n");
                    fix(end_pos, end_pos, "\n}");
                }
            }
        }
    }
}
