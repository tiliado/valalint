public class Linter.Block {
    public Vala.SourceLocation begin;
    public Vala.SourceLocation end;

    public Block (Vala.SourceLocation begin) {
        this.begin = begin;
    }
}
