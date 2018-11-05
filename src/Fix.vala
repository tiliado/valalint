public class Linter.Fix {
    public Vala.SourceFile file;
    public int begin;
    public int end;
    public string? replacement;

    public Fix(Vala.SourceFile file, int begin, int end, owned string? replacement) {
        this.file = file;
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
