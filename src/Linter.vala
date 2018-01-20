public class Linter.Linter {
    public Vala.CodeContext? context { get; set; }
    public Vala.SourceFile current_source_file { get; set; }
    private Rule[] rules;
    private Vala.HashMap<string, string?> params;

    public Linter(owned Rule[] rules, Vala.HashMap<string, string?> params) {
        this.rules = (owned) rules;
        this.params = params;
    }

    public void lint(Vala.CodeContext context) {
        this.context = context;
        var iter = params.map_iterator();
        while(iter.next()) {
            foreach (var rule in rules) {
                rule.setup(iter.get_key(), iter.get_value());
            }
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
