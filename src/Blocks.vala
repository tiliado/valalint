public class Linter.Blocks {
    public Vala.Map<char*, Block> map = new Vala.HashMap<char*, Block>();
    Vala.List<Block> stack = new Vala.ArrayList<Block>();

    public Blocks(TokenList tokens) {
        Token? token = null;
        Block? current_block = null;
        while (tokens.next(out token)) {
            switch (token.type) {
                case Vala.TokenType.OPEN_BRACE:
                    current_block = new Block(token.begin);
                    stack.add(current_block);
                    map[token.begin.pos] = current_block;
                break;
                case Vala.TokenType.CLOSE_BRACE:
                    assert(current_block != null);
                    current_block.end = token.end;
                    stack.remove(current_block);
                    if (stack.size > 0) {
                        current_block = stack[stack.size - 1];
                    } else {
                        current_block = null;
                    }
                break;
            }
        }
    }

    public Block? find(char* pos) {
        while (pos != null) {
            char c = *pos;
            switch (c) {
                case ' ':
                case '\t':
                case '\n':
                case '\r':
                    pos++;
                    break;
                case '{':
                    return map[pos];
                default:
                    return null;
            }
        }
        return null;
    }
}
