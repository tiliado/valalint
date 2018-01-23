public class Linter.Fix {
    public Vala.SourceFile file;
    public char* content;
    public char* begin;
    public char* end;
    public string? replacement;

    public Fix(Vala.SourceFile file, char* begin, char* end, owned string? replacement) {
        this.file = file;
        this.content = file.get_mapped_contents();
        this.begin = begin;
        this.end = end;
        this.replacement = (owned) replacement;
    }

    public int compare(Fix other) {
        return (int) (this.begin - other.begin);
    }

    public static int compare_func(Fix a, Fix b) {
        return a.compare(b);
    }

}
