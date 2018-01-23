public class Linter.Linter {
    public Vala.CodeContext? context { get; set; }
    public Vala.SourceFile current_source_file { get; set; }
    public Rule[] rules;
    public Config config;

    public Linter(owned Rule[] rules, Config config) {
        this.rules = (owned) rules;
        this.config = config;
    }

    public void lint(Vala.CodeContext context, CodeVisitor visitor) {
        this.context = context;
        foreach (var rule in rules) {
            rule.setup(config);
        }

        Vala.List<Vala.SourceFile> files = context.get_source_files();
        bool dump_tree = visitor.dump_tree;
        foreach (var file in files) {
            if (file.filename.has_suffix(".vala")) {
                var tokens = new TokenList.from_source(file);
                var blocks = new Blocks(tokens);
                visitor.dump_tree = dump_tree;
                foreach (var rule in rules) {
                    rule.apply(file, tokens.copy(true), blocks);
                    visitor.apply_rule(rule, file);
                    visitor.dump_tree = false;
                    rule.reset();
                }
            }
        }
    }
}
