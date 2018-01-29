public class Linter.CodeVisitor : Vala.CodeVisitor {
    public bool dump_tree {get; set; default = false;}
    protected Vala.SourceFile current_file = null;
    protected int level = 0;
    protected unowned FileStream fout = stdout;
    private Rule? rule = null;
    private Vala.List<string>? open_nodes = null;
    private bool empty_node = false;


    public CodeVisitor(bool dump_tree=false) {
        this.dump_tree = dump_tree;
    }

    protected void indent() {
        if (level > 0) {
            fout.puts(string.nfill(4 * level, ' '));
        }
    }

    public void apply_rule(Rule rule, Vala.SourceFile file) {
        this.rule = rule;
        current_file = file;
        open_nodes = new Vala.ArrayList<string>(str_equal);
        empty_node = false;
        visit_source_file(file);
        this.rule = null;
        current_file = null;
        open_nodes = null;
    }

    public override void visit_source_file(Vala.SourceFile file) {
        level = 0;
        FileStream stream = FileStream.open(dump_tree ? file.filename + ".txt" : "/dev/null", "w");
        fout = stream;
        rule.lint_source_file(file);
        file.accept_children(this);
        fout = stdout;
    }

    /**
     * Visit operation called for classes.
     *
     * @param cl a class
     */
    public override void visit_class (Vala.Class cl) {
        open("class %s", cl.name);
        cl.accept_children(this);
        close();
    }

    /**
     * Visit operation called for structs.
     *
     * @param st a struct
     */
    public override void visit_struct (Vala.Struct st) {
        open("struct %s", st.name);
        st.accept_children(this);
        close();
    }

    /**
     * Visit operation called for interfaces.
     *
     * @param iface an interface
     */
    public override void visit_interface (Vala.Interface iface) {
        open("interface %s", iface.name);
        iface.accept_children(this);
        close();
    }

    /**
     * Visit operation called for enums.
     *
     * @param en an enum
     */
    public override void visit_enum (Vala.Enum en) {
        open("enum %s", en.name);
        en.accept_children(this);
        close();
    }

    /**
     * Visit operation called for enum values.
     *
     * @param ev an enum value
     */
    public override void visit_enum_value (Vala.EnumValue ev) {
        open("value %s", ev.name);
        ev.accept_children(this);
        close();
    }

    /**
     * Visit operation called for error domains.
     *
     * @param edomain an error domain
     */
    public override void visit_error_domain (Vala.ErrorDomain edomain) {
        open("error %s", edomain.name);
        edomain.accept_children(this);
        close();
    }

    /**
     * Visit operation called for error codes.
     *
     * @param ecode an error code
     */
    public override void visit_error_code (Vala.ErrorCode ecode) {
        open("code %s", ecode.name);
        ecode.accept_children(this);
        close();
    }

    /**
     * Visit operation called for delegates.
     *
     * @param d a delegate
     */
    public override void visit_delegate (Vala.Delegate d) {
        open("delegate %s", d.name);
        d.accept_children(this);
        close();
    }

    /**
     * Visit operation called for constants.
     *
     * @param c a constant
     */
    public override void visit_constant (Vala.Constant c) {
        open("const %s", c.name);
        c.accept_children(this);
        close();
    }

    /**
     * Visit operation called for fields.
     *
     * @param f a field
     */
    public override void visit_field (Vala.Field f) {
        if (f.external_package) {
            return;
        }
        Vala.DataType variable_type = f.variable_type;
        open("field %s %s ", f.name, variable_type != null ? variable_type.to_string() : null);
        f.accept_children(this);
        close();
    }

    /**
     * Visit operation called for methods.
     *
     * @param m a method
     */
    public override void visit_method (Vala.Method m) {
        open("method %s", m.name);
        m.accept_children(this);
        close();
    }

    /**
     * Visit operation called for creation methods.
     *
     * @param m a method
     */
    public override void visit_creation_method (Vala.CreationMethod m) {
        open("creation method %s", m.name);
        m.accept_children(this);
        close();
    }

    /**
     * Visit operation called for formal parameters.
     *
     * @param p a formal parameter
     */
    public override void visit_formal_parameter (Vala.Parameter p) {
        open("formal param %s", p.name);
        p.accept_children(this);
        close();
    }

    /**
     * Visit operation called for properties.
     *
     * @param prop a property
     */
    public override void visit_property (Vala.Property prop) {
        open("property %s", prop.name);
        prop.accept_children(this);
        close();
    }

    /**
     * Visit operation called for property accessors.
     *
     * @param acc a property accessor
     */
    public override void visit_property_accessor (Vala.PropertyAccessor acc) {
        string spec = "";
        if (acc.readable) {
            spec += " get";
        }
        if (acc.writable) {
            spec += " set";
        }
        if (acc.construction) {
            spec += " construct";
        }
        open("property accessor %s", spec);
        acc.accept_children(this);
        close();
    }

    /**
     * Visit operation called for signals.
     *
     * @param sig a signal
     */
    public override void visit_signal (Vala.Signal sig) {
        open("signal %s", sig.name);
        sig.accept_children(this);
        close();
    }

    /**
     * Visit operation called for constructors.
     *
     * @param c a constructor
     */
    public override void visit_constructor (Vala.Constructor c) {
        open("constructor %s", c.name);
        c.accept_children(this);
        close();
    }

    /**
     * Visit operation called for destructors.
     *
     * @param d a destructor
     */
    public override void visit_destructor (Vala.Destructor d) {
        open("destructor %s", d.name);
        d.accept_children(this);
        close();
    }

    /**
     * Visit operation called for type parameters.
     *
     * @param p a type parameter
     */
    public override void visit_type_parameter (Vala.TypeParameter p) {
        open("type param %s", p.name);
        p.accept_children(this);
        close();
    }

    /**
     * Visit operation called for using directives.
     *
     * @param ns a using directive
     */
    public override void visit_using_directive (Vala.UsingDirective ns) {
        open("using %s", ns.namespace_symbol.name);
        ns.accept_children(this);
        close();
    }

    /**
     * Visit operation called for type references.
     *
     * @param type a type reference
     */
    public override void visit_data_type (Vala.DataType type) {
        open("data type %s", type.to_string());
        rule.lint_data_type(type);
        type.accept_children(this);
        close();
    }

    /**
     * Visit operation called for blocks.
     *
     * @param b a block
     */
    public override void visit_block (Vala.Block b) {
        open("block");
        b.accept_children(this);
        close();
    }

    /**
     * Visit operation called for empty statements.
     *
     * @param stmt an empty statement
     */
    public override void visit_empty_statement (Vala.EmptyStatement stmt) {
        open("empty statement");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for declaration statements.
     *
     * @param stmt a declaration statement
     */
    public override void visit_declaration_statement (Vala.DeclarationStatement stmt) {
        open("declaration stm");
        rule.lint_declaration_statement(stmt);
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for local variables.
     *
     * @param local a local variable
     */
    public override void visit_local_variable (Vala.LocalVariable local) {
        open("local %s", local.name);
        rule.lint_local_variable(local);
        local.accept_children(this);
        close();
    }

    /**
     * Visit operation called for initializer lists
     *
     * @param list an initializer list
     */
    public override void visit_initializer_list (Vala.InitializerList list) {
        open("initializer list");
        list.accept_children(this);
        close();
    }

    /**
     * Visit operation called for expression statements.
     *
     * @param stmt an expression statement
     */
    public override void visit_expression_statement (Vala.ExpressionStatement stmt) {
        open("expression stm");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for if statements.
     *
     * @param stmt an if statement
     */
    public override void visit_if_statement (Vala.IfStatement stmt) {
        open("if");
        rule.lint_if_statement(stmt);
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for switch statements.
     *
     * @param stmt a switch statement
     */
    public override void visit_switch_statement (Vala.SwitchStatement stmt) {
        open("switch stm");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for switch sections.
     *
     * @param section a switch section
     */
    public override void visit_switch_section (Vala.SwitchSection section) {
        open("switch section");
        section.accept_children(this);
        close();
    }

    /**
     * Visit operation called for switch label.
     *
     * @param label a switch label
     */
    public override void visit_switch_label (Vala.SwitchLabel label) {
        open("switch label");
        label.accept_children(this);
        close();
    }

    /**
     * Visit operation called for loops.
     *
     * @param stmt a loop
     */
    public override void visit_loop (Vala.Loop stmt) {
        open("loop");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for while statements.
     *
     * @param stmt an while statement
     */
    public override void visit_while_statement (Vala.WhileStatement stmt) {
        open("while");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for do statements.
     *
     * @param stmt a do statement
     */
    public override void visit_do_statement (Vala.DoStatement stmt) {
        open("do");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for for statements.
     *
     * @param stmt a for statement
     */
    public override void visit_for_statement (Vala.ForStatement stmt) {
        open("for");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for foreach statements.
     *
     * @param stmt a foreach statement
     */
    public override void visit_foreach_statement (Vala.ForeachStatement stmt) {
        open("foreach");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for break statements.
     *
     * @param stmt a break statement
     */
    public override void visit_break_statement (Vala.BreakStatement stmt) {
        open("break");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for continue statements.
     *
     * @param stmt a continue statement
     */
    public override void visit_continue_statement (Vala.ContinueStatement stmt) {
        open("continue");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for return statements.
     *
     * @param stmt a return statement
     */
    public override void visit_return_statement (Vala.ReturnStatement stmt) {
        open("return");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for yield statement.
     *
     * @param y a yield statement
     */
    public override void visit_yield_statement (Vala.YieldStatement stmt) {
        open("yield");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for throw statements.
     *
     * @param stmt a throw statement
     */
    public override void visit_throw_statement (Vala.ThrowStatement stmt) {
        open("throw");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for try statements.
     *
     * @param stmt a try statement
     */
    public override void visit_try_statement (Vala.TryStatement stmt) {
        open("try");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for catch clauses.
     *
     * @param clause a catch cluase
     */
    public override void visit_catch_clause (Vala.CatchClause clause) {
        open("catch");
        clause.accept_children(this);
        close();
    }

    /**
     * Visit operation called for lock statements before the body has been visited.
     *
     * @param stmt a lock statement
     */
    public override void visit_lock_statement (Vala.LockStatement stmt) {
        open("lock");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for unlock statements.
     *
     * @param stmt an unlock statement
     */
    public override void visit_unlock_statement (Vala.UnlockStatement stmt) {
        open("unlock");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operation called for delete statements.
     *
     * @param stmt a delete statement
     */
    public override void visit_delete_statement (Vala.DeleteStatement stmt) {
        open("delete");
        stmt.accept_children(this);
        close();
    }

    /**
     * Visit operations called for expresions.
     *
     * @param expr an expression
     */
    public override void visit_expression (Vala.Expression expr) {
        rule.lint_expression(expr);
    }

    /**
     * Visit operations called for array creation expresions.
     *
     * @param expr an array creation expression
     */
    public override void visit_array_creation_expression (Vala.ArrayCreationExpression expr) {
        open("expr: array creation");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for boolean literals.
     *
     * @param lit a boolean literal
     */
    public override void visit_boolean_literal (Vala.BooleanLiteral lit) {
        open("boolean");
        lit.accept_children(this);
        close();
    }

    /**
     * Visit operation called for character literals.
     *
     * @param lit a character literal
     */
    public override void visit_character_literal (Vala.CharacterLiteral lit) {
        open("character");
        lit.accept_children(this);
        close();
    }

    /**
     * Visit operation called for integer literals.
     *
     * @param lit an integer literal
     */
    public override void visit_integer_literal (Vala.IntegerLiteral lit) {
        open("integer");
        lit.accept_children(this);
        close();
    }

    /**
     * Visit operation called for real literals.
     *
     * @param lit a real literal
     */
    public override void visit_real_literal (Vala.RealLiteral lit) {
        open("real");
        lit.accept_children(this);
        close();
    }

    /**
     * Visit operation called for regex literals.
     *
     * @param lit a regex literal
     */
    public override void visit_regex_literal (Vala.RegexLiteral lit) {
        open("regex");
        lit.accept_children(this);
        close();
    }


    /**
     * Visit operation called for string literals.
     *
     * @param lit a string literal
     */
    public override void visit_string_literal (Vala.StringLiteral lit) {
        open("string");
        lit.accept_children(this);
        close();
    }

    /**
     * Visit operation called for string templates.
     *
     * @param tmpl a string template
     */
    public override void visit_template (Vala.Template tmpl) {
        open("template");
        tmpl.accept_children(this);
        close();
    }

    /**
     * Visit operation called for tuples.
     *
     * @param tuple a tuple
     */
    public override void visit_tuple (Vala.Tuple tuple) {
        open("tuple");
        tuple.accept_children(this);
        close();
    }

    /**
     * Visit operation called for null literals.
     *
     * @param lit a null literal
     */
    public override void visit_null_literal (Vala.NullLiteral lit) {
        open("null");
        lit.accept_children(this);
        close();
    }

    /**
     * Visit operation called for member access expressions.
     *
     * @param expr a member access expression
     */
    public override void visit_member_access (Vala.MemberAccess expr) {

        string name = "";
        if (expr.inner != null) {
            name += expr.inner.to_string() + ".";
        }
        name += expr.member_name;
        open("member access: %s", name);
        close();
    }

    /**
     * Visit operation called for invocation expressions.
     *
     * @param expr an invocation expression
     */
    public override void visit_method_call (Vala.MethodCall expr) {
        open("expr: call");
        rule.lint_method_call(expr);
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for element access expressions.
     *
     * @param expr an element access expression
     */
    public override void visit_element_access (Vala.ElementAccess expr) {
        open("element access");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for array slice expressions.
     *
     * @param expr an array slice expression
     */
    public override void visit_slice_expression (Vala.SliceExpression expr) {
        open("slice");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for base access expressions.
     *
     * @param expr a base access expression
     */
    public override void visit_base_access (Vala.BaseAccess expr) {
        open("base access");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for postfix expressions.
     *
     * @param expr a postfix expression
     */
    public override void visit_postfix_expression (Vala.PostfixExpression expr) {
        open("postfix");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for object creation expressions.
     *
     * @param expr an object creation expression
     */
    public override void visit_object_creation_expression (Vala.ObjectCreationExpression expr) {
        open("object creation");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for sizeof expressions.
     *
     * @param expr a sizeof expression
     */
    public override void visit_sizeof_expression (Vala.SizeofExpression expr) {
        open("sizeof");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for typeof expressions.
     *
     * @param expr a typeof expression
     */
    public override void visit_typeof_expression (Vala.TypeofExpression expr) {
        open("typeof");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for unary expressions.
     *
     * @param expr an unary expression
     */
    public override void visit_unary_expression (Vala.UnaryExpression expr) {
        open("unary expr %s", expr.operator.to_string());
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for call expressions.
     *
     * @param expr a call expression
     */
    public override void visit_cast_expression (Vala.CastExpression expr) {
        open("cast");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for named arguments.
     *
     * @param expr a named argument
     */
    public override void visit_named_argument (Vala.NamedArgument expr) {
        open("named arg");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for pointer indirections.
     *
     * @param expr a pointer indirection
     */
    public override void visit_pointer_indirection (Vala.PointerIndirection expr) {
        open("pointer indirection");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for address-of expressions.
     *
     * @param expr an address-of expression
     */
    public override void visit_addressof_expression (Vala.AddressofExpression expr) {
        open("addressof");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for reference transfer expressions.
     *
     * @param expr a reference transfer expression
     */
    public override void visit_reference_transfer_expression (Vala.ReferenceTransferExpression expr) {
        open("ref transfer");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for binary expressions.
     *
     * @param expr a binary expression
     */
    public override void visit_binary_expression (Vala.BinaryExpression expr) {
        open("binary expr %s", expr.operator.to_string());
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for type checks.
     *
     * @param expr a type check expression
     */
    public override void visit_type_check (Vala.TypeCheck expr) {
        open("type check");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for conditional expressions.
     *
     * @param expr a conditional expression
     */
    public override void visit_conditional_expression (Vala.ConditionalExpression expr) {
        open("conditional expr");
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for lambda expressions.
     *
     * @param expr a lambda expression
     */
    public override void visit_lambda_expression (Vala.LambdaExpression expr) {
        open("expr: lambda");
        rule.lint_lambda_expression(expr);
        expr.accept_children(this);
        close();
    }

    /**
     * Visit operation called for assignments.
     *
     * @param a an assignment
     */
    public override void visit_assignment (Vala.Assignment a) {
        open("expr: assignment");
        rule.lint_assignment(a);
        a.accept_children(this);
        close();
    }

    private void open(string format, ...) {
        if (empty_node) {
            fout.puts(">\n");
            empty_node = false;
        }
        string text = format.vprintf(va_list());
        indent();
        fout.printf("<%s", text);
        open_nodes.add((owned) text);
        empty_node = true;
        level++;
    }

    private void close() {
        level--;
        string text = open_nodes.remove_at(open_nodes.size - 1);
        if (empty_node) {
            fout.puts(" />\n");
            empty_node = false;
        } else {
            indent();
            fout.printf("</%s>\n", text);
        }
    }
}
