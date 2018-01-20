public class Linter.Token {
    public Vala.TokenType type;
    public Vala.SourceLocation begin;
    public Vala.SourceLocation end;

    public Token(Vala.TokenType type, Vala.SourceLocation begin, Vala.SourceLocation end) {
        this.type = type;
        this.begin = begin;
        this.end = end;
    }

    public string to_string() {
        return "%d.%d-%d.%d %s".printf(begin.line, begin.column, end.line, end.column, type.to_string());
    }
}
