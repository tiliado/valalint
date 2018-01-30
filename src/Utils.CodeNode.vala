namespace Linter.Utils.CodeNode {

public inline bool same_start(Vala.CodeNode node1, Vala.CodeNode node2) {
    return node1.source_reference.begin.pos == node2.source_reference.begin.pos;
}

public char* find_end_of_stm(char* pos, Vala.Statement? stm) {
    if (stm == null) return pos;
    var if_stm = stm as Vala.IfStatement;
    var foreach_stm = stm as Vala.ForeachStatement;
    var for_stm = stm as Vala.ForStatement;
    var while_stm = stm as Vala.WhileStatement;
    var block_stm = stm as Vala.Block;
    if (while_stm != null) pos = find_end_of_stm(pos, while_stm.body);
    if (for_stm != null) pos = find_end_of_stm(pos, for_stm.body);
    if (foreach_stm != null) pos = find_end_of_stm(pos, foreach_stm.body);
    if (if_stm != null) {
        pos = find_end_of_stm(pos, if_stm.true_statement);
        pos = find_end_of_stm(pos, if_stm.false_statement);
    }
    if (block_stm != null) {
        foreach (Vala.Statement st in block_stm.get_statements()) {
            pos = find_end_of_stm(pos, st);
        }
    }
    if (stm.source_reference.end.pos > pos) {
        pos = stm.source_reference.end.pos;
        if (block_stm != null) {
            /* block_stm.source_reference.end.pos goes beyond '}'! */
            while (*(pos - 1) != '}') {
                pos--;
            }
        }
    }
    return pos;
}

} // namespace Linter.Utils.CodeNode
