public class Linter.Linter {
    public Vala.CodeContext? context { get; set; }
    public Vala.SourceFile current_source_file { get; set; }
    private Rule[] rules;
    private Config config;

    public Linter(owned Rule[] rules, Config config) {
        this.rules = (owned) rules;
        this.config = config;
    }

    public void lint(Vala.CodeContext context) {
        this.context = context;
        foreach (var rule in rules) {
            rule.setup(config);
        }

        Vala.List<Vala.SourceFile> files = context.get_source_files();
        foreach (var file in files) {
            if (file.filename.has_suffix(".vala")) {
                var tokens = new TokenList.from_source(file);
                var blocks = new Blocks(tokens);
                Vala.List<Vala.CodeNode> nodes = file.get_nodes();
                Vala.CodeNode[] nodes_to_remove = {};
                foreach (var node in nodes) {
                    var ns = node as Vala.Namespace;
                    if (ns != null && ns.parent_symbol != null && ns.parent_symbol.name != null) {
                        nodes_to_remove += node;
                    }
                }
                foreach (var node in nodes_to_remove) {
                    file.remove_node(node);
                }
                foreach (var rule in rules) {
                   rule.apply(file, tokens.copy(true), blocks);
                }
            }
        }
    }
}
