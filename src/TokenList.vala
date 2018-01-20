public class Linter.TokenList {
    private Vala.List<Token> tokens;
    public int pos {get; private set;}
    private int size {get; private set;}

    public TokenList(Vala.List<Token> tokens, int pos=0) {
        this.tokens = tokens;
        this.size = tokens.size;
        this.pos = 0 <= pos < size ? pos : 0;
    }

    public TokenList.from_source(Vala.SourceFile source_file) {
        var tokens = new Vala.ArrayList<Token>();
        var scanner = new Vala.Scanner(source_file);
        Vala.TokenType token_type = Vala.TokenType.NONE;
        Vala.SourceLocation token_begin;
        Vala.SourceLocation token_end;
        while (((token_type = scanner.read_token(out token_begin, out token_end)) != Vala.TokenType.EOF)) {
            tokens.add(new Token(token_type, token_begin, token_end));
        }
        this(tokens, 0);
    }

    public void reset() {
        pos = 0;
    }

    public bool next(out Token? token) {
        if (pos < size) {
            token = tokens[pos++];
            return true;
        } else {
            token = null;
            return false;
        }
    }

    public Token? get(int pos) {
        return (0 <= pos < size) ? tokens[pos] : null;
    }

    public bool move(int step=1) {
        int pos = this.pos + step;
        if (0 <= pos < size) {
            this.pos = pos;
            return true;
        }
        return false;
    }

    public bool peek(int step, out Token? token) {
        var pos = this.pos + step - 1;
        if (0 <= pos < size) {
            token = tokens[pos];
            return true;
        } else {
            token = null;
            return false;
        }
    }

    public TokenList iter() {
        return copy(true);
    }

    public TokenList copy(bool reset) {
        return new TokenList(tokens, reset ? 0 : pos);
    }
}
