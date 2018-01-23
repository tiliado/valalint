public class Linter.VariableRule : Rule {
    public bool var_keyword_never {get; set; default = false;}
    public bool var_keyword_array_creation {get; set; default = false;}
    public bool var_keyword_object_creation {get; set; default = false;}
    public bool var_keyword_cast {get; set; default = false;}

    public VariableRule() {
        base();
    }

    public override void setup(Config config) {
        base.setup(config);
        var_keyword_never = config.get_bool_or(Config.CHECKS, "var_keyword_never");
        var_keyword_object_creation = config.get_bool_or(Config.CHECKS, "var_keyword_object_creation");
        var_keyword_array_creation = config.get_bool_or(Config.CHECKS, "var_keyword_array_creation");
        var_keyword_cast = config.get_bool_or(Config.CHECKS, "var_keyword_cast");
    }

    public override void lint_declaration_statement(Vala.DeclarationStatement stm) {
        var declaration = stm.declaration as Vala.LocalVariable;
        Vala.Expression? initializer = declaration.initializer;
        if (declaration.variable_type == null) {
            if (var_keyword_never) {
                error(
                    stm.source_reference.begin,
                    stm.source_reference.end,
                    "The `var` keyword is not allowed.");
            } else if (var_keyword_array_creation || var_keyword_object_creation || var_keyword_cast) {
                var object = initializer as Vala.ObjectCreationExpression;
                var cast = initializer as Vala.CastExpression;
                var array = initializer as Vala.ArrayCreationExpression;
                if (!(object != null && var_keyword_object_creation
                || array != null && var_keyword_array_creation
                || cast != null && var_keyword_cast)) {
                    error(
                        stm.source_reference.begin,
                        stm.source_reference.end,
                        "The `var` keyword is not allowed for variable initialization with %s.",
                        initializer.type_name);
                }
            }
        }

    }
}
