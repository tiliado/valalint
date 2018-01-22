public class Linter.CodeVisitor : Vala.CodeVisitor {
    public bool dump_tree {get; set; default = false;}
    protected Vala.SourceFile current_file = null;
    protected int level = 0;
    protected unowned FileStream fout = stdout;
    private Rule? rule = null;


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
        visit_source_file(file);
        this.rule = null;
        current_file = null;
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
        indent();
        fout.printf("<class %s>\n", cl.name);
        level++;
        cl.accept_children(this);
        level--;
        indent();
        fout.printf("</class %s>\n", cl.name);
    }

    /**
     * Visit operation called for structs.
     *
     * @param st a struct
     */
    public override void visit_struct (Vala.Struct st) {
        indent();
        fout.printf("<struct %s>\n", st.name);
        level++;
        st.accept_children(this);
        level--;
        indent();
        fout.printf("</struct %s>\n", st.name);
    }

    /**
     * Visit operation called for interfaces.
     *
     * @param iface an interface
     */
    public override void visit_interface (Vala.Interface iface) {
        indent();
        fout.printf("<interface %s>\n", iface.name);
        level++;
        iface.accept_children(this);
        level--;
        indent();
        fout.printf("</interface %s>\n", iface.name);
    }

    /**
     * Visit operation called for enums.
     *
     * @param en an enum
     */
    public override void visit_enum (Vala.Enum en) {
        indent();
        fout.printf("<enum %s>\n", en.name);
        level++;
        en.accept_children(this);
        level--;
        indent();
        fout.printf("</enum %s>\n", en.name);
    }

    /**
     * Visit operation called for enum values.
     *
     * @param ev an enum value
     */
    public override void visit_enum_value (Vala.EnumValue ev) {
        indent();
        fout.printf("<value %s>\n", ev.name);
        level++;
        ev.accept_children(this);
        level--;
        indent();
        fout.printf("</value %s>\n", ev.name);
    }

    /**
     * Visit operation called for error domains.
     *
     * @param edomain an error domain
     */
    public override void visit_error_domain (Vala.ErrorDomain edomain) {
        indent();
        fout.printf("<error %s>\n", edomain.name);
        level++;
        edomain.accept_children(this);
        level--;
        indent();
        fout.printf("</error %s>\n", edomain.name);
    }

    /**
     * Visit operation called for error codes.
     *
     * @param ecode an error code
     */
    public override void visit_error_code (Vala.ErrorCode ecode) {
        indent();
        fout.printf("<code %s>\n", ecode.name);
        level++;
        ecode.accept_children(this);
        level--;
        indent();
        fout.printf("<code %s>\n", ecode.name);
    }

    /**
     * Visit operation called for delegates.
     *
     * @param d a delegate
     */
    public override void visit_delegate (Vala.Delegate d) {
        indent();
        fout.printf("<delegate %s>\n", d.name);
        level++;
        d.accept_children(this);
        level--;
        indent();
        fout.printf("</delegate %s>\n", d.name);
    }

    /**
     * Visit operation called for constants.
     *
     * @param c a constant
     */
    public override void visit_constant (Vala.Constant c) {
        indent();
        fout.printf("<const %s>\n", c.name);
        level++;
        c.accept_children(this);
        level--;
        indent();
        fout.printf("</const %s>\n", c.name);
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
        indent();
        var variable_type = f.variable_type;
        fout.printf("<field %s %s >\n", f.name, variable_type != null ? variable_type.to_string() : null);
        level++;
        f.accept_children(this);
        level--;
        indent();
        fout.printf("</field %s>\n", f.name);
    }

    /**
     * Visit operation called for methods.
     *
     * @param m a method
     */
    public override void visit_method (Vala.Method m) {
        indent();
        fout.printf("<method %s>\n", m.name);
        level++;
        m.accept_children(this);
        level--;
        indent();
        fout.printf("</method %s>\n", m.name);
    }

    /**
     * Visit operation called for creation methods.
     *
     * @param m a method
     */
    public override void visit_creation_method (Vala.CreationMethod m) {
        indent();
        fout.printf("<creation method %s>\n", m.name);
        level++;
        m.accept_children(this);
        level--;
        indent();
        fout.printf("</creation method %s>\n", m.name);
    }

    /**
     * Visit operation called for formal parameters.
     *
     * @param p a formal parameter
     */
    public override void visit_formal_parameter (Vala.Parameter p) {
        indent();
        fout.printf("<formal param %s>\n", p.name);
        level++;
        p.accept_children(this);
        level--;
        indent();
        fout.printf("</formal param %s>\n", p.name);
    }

    /**
     * Visit operation called for properties.
     *
     * @param prop a property
     */
    public override void visit_property (Vala.Property prop) {
        indent();
        fout.printf("<property %s>\n", prop.name);
        level++;
        prop.accept_children(this);
        level--;
        indent();
        fout.printf("</property %s>\n", prop.name);
    }

    /**
     * Visit operation called for property accessors.
     *
     * @param acc a property accessor
     */
    public override void visit_property_accessor (Vala.PropertyAccessor acc) {
        indent();
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
        fout.printf("<property accessor %s>\n", spec);
        level++;
        acc.accept_children(this);
        level--;
        indent();
        fout.printf("</property accessor %s>\n", spec);
    }

    /**
     * Visit operation called for signals.
     *
     * @param sig a signal
     */
    public override void visit_signal (Vala.Signal sig) {
        indent();
        fout.printf("<signal %s>\n", sig.name);
        level++;
        sig.accept_children(this);
        level--;
        indent();
        fout.printf("</signal %s>\n", sig.name);
    }

    /**
     * Visit operation called for constructors.
     *
     * @param c a constructor
     */
    public override void visit_constructor (Vala.Constructor c) {
        indent();
        fout.printf("<constructor %s>\n", c.name);
        level++;
        c.accept_children(this);
        level--;
        indent();
        fout.printf("</constructor %s>\n", c.name);
    }

    /**
     * Visit operation called for destructors.
     *
     * @param d a destructor
     */
    public override void visit_destructor (Vala.Destructor d) {
        indent();
        fout.printf("<destructor %s>\n", d.name);
        level++;
        d.accept_children(this);
        level--;
        indent();
        fout.printf("</destructor %s>\n", d.name);
    }

    /**
     * Visit operation called for type parameters.
     *
     * @param p a type parameter
     */
    public override void visit_type_parameter (Vala.TypeParameter p) {
        indent();
        fout.printf("<type param %s>\n", p.name);
        level++;
        p.accept_children(this);
        level--;
        indent();
        fout.printf("</type param %s>\n", p.name);
    }

    /**
     * Visit operation called for using directives.
     *
     * @param ns a using directive
     */
    public override void visit_using_directive (Vala.UsingDirective ns) {
        indent();
        fout.printf("<using %s>\n", ns.namespace_symbol.name);
        level++;
        ns.accept_children(this);
        level--;
        indent();
        fout.printf("</using %s>\n", ns.namespace_symbol.name);
    }

    /**
     * Visit operation called for type references.
     *
     * @param type a type reference
     */
    public override void visit_data_type (Vala.DataType type) {
        indent();
        fout.printf("<data type %s>\n", type.to_string());
        level++;
        type.accept_children(this);
        level--;
        indent();
        fout.printf("</data type %s>\n", type.to_string());
    }

    /**
     * Visit operation called for blocks.
     *
     * @param b a block
     */
    public override void visit_block (Vala.Block b) {
        indent();
        fout.printf("<block>\n");
        level++;
        b.accept_children(this);
        level--;
        indent();
        fout.printf("</block>\n");
    }

    /**
     * Visit operation called for empty statements.
     *
     * @param stmt an empty statement
     */
    public override void visit_empty_statement (Vala.EmptyStatement stmt) {
        indent();
        fout.printf("<empty statement>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("<empty statement>\n");
    }

    /**
     * Visit operation called for declaration statements.
     *
     * @param stmt a declaration statement
     */
    public override void visit_declaration_statement (Vala.DeclarationStatement stmt) {
        indent();
        fout.printf("<declaration stm>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</declaration stm>\n");
    }

    /**
     * Visit operation called for local variables.
     *
     * @param local a local variable
     */
    public override void visit_local_variable (Vala.LocalVariable local) {
        indent();
        fout.printf("<local %s>\n", local.name);
        level++;
        local.accept_children(this);
        level--;
        indent();
        fout.printf("</local %s>\n", local.name);
    }

    /**
     * Visit operation called for initializer lists
     *
     * @param list an initializer list
     */
    public override void visit_initializer_list (Vala.InitializerList list) {
        indent();
        fout.printf("<initializer list>\n");
        level++;
        list.accept_children(this);
        level--;
        indent();
        fout.printf("<initializer list>\n");
    }

    /**
     * Visit operation called for expression statements.
     *
     * @param stmt an expression statement
     */
    public override void visit_expression_statement (Vala.ExpressionStatement stmt) {
        indent();
        fout.printf("<expression stm>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</expression stm>\n");
    }

    /**
     * Visit operation called for if statements.
     *
     * @param stmt an if statement
     */
    public override void visit_if_statement (Vala.IfStatement stmt) {
        indent();
        fout.printf("<if>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</if>\n");
    }

    /**
     * Visit operation called for switch statements.
     *
     * @param stmt a switch statement
     */
    public override void visit_switch_statement (Vala.SwitchStatement stmt) {
        indent();
        fout.printf("<switch stm>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</switch stm>\n");
    }

    /**
     * Visit operation called for switch sections.
     *
     * @param section a switch section
     */
    public override void visit_switch_section (Vala.SwitchSection section) {
        indent();
        fout.printf("<switch section>\n");
        level++;
        section.accept_children(this);
        level--;
        indent();
        fout.printf("</switch section>\n");
    }

    /**
     * Visit operation called for switch label.
     *
     * @param label a switch label
     */
    public override void visit_switch_label (Vala.SwitchLabel label) {
        indent();
        fout.printf("<switch label>\n");
        level++;
        label.accept_children(this);
        level--;
        indent();
        fout.printf("</switch label>\n");
    }

    /**
     * Visit operation called for loops.
     *
     * @param stmt a loop
     */
    public override void visit_loop (Vala.Loop stmt) {
        indent();
        fout.printf("<loop>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</loop>\n");
    }

    /**
     * Visit operation called for while statements.
     *
     * @param stmt an while statement
     */
    public override void visit_while_statement (Vala.WhileStatement stmt) {
        indent();
        fout.printf("<while>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("<while>\n");
    }

    /**
     * Visit operation called for do statements.
     *
     * @param stmt a do statement
     */
    public override void visit_do_statement (Vala.DoStatement stmt) {
        indent();
        fout.printf("<do>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</do>\n");
    }

    /**
     * Visit operation called for for statements.
     *
     * @param stmt a for statement
     */
    public override void visit_for_statement (Vala.ForStatement stmt) {
        indent();
        fout.printf("<for>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</for>\n");
    }

    /**
     * Visit operation called for foreach statements.
     *
     * @param stmt a foreach statement
     */
    public override void visit_foreach_statement (Vala.ForeachStatement stmt) {
        indent();
        fout.printf("<foreach>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</foreach>\n");
    }

    /**
     * Visit operation called for break statements.
     *
     * @param stmt a break statement
     */
    public override void visit_break_statement (Vala.BreakStatement stmt) {
        indent();
        fout.printf("<break>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</break>\n");
    }

    /**
     * Visit operation called for continue statements.
     *
     * @param stmt a continue statement
     */
    public override void visit_continue_statement (Vala.ContinueStatement stmt) {
        indent();
        fout.printf("<continue>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</continue>\n");
    }

    /**
     * Visit operation called for return statements.
     *
     * @param stmt a return statement
     */
    public override void visit_return_statement (Vala.ReturnStatement stmt) {
        indent();
        fout.printf("<return>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</return>\n");
    }

    /**
     * Visit operation called for yield statement.
     *
     * @param y a yield statement
     */
    public override void visit_yield_statement (Vala.YieldStatement stmt) {
        indent();
        fout.printf("<yield>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</yield>\n");
    }

    /**
     * Visit operation called for throw statements.
     *
     * @param stmt a throw statement
     */
    public override void visit_throw_statement (Vala.ThrowStatement stmt) {
        indent();
        fout.printf("<throw>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</throw>\n");
    }

    /**
     * Visit operation called for try statements.
     *
     * @param stmt a try statement
     */
    public override void visit_try_statement (Vala.TryStatement stmt) {
        indent();
        fout.printf("<try>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</try>\n");
    }

    /**
     * Visit operation called for catch clauses.
     *
     * @param clause a catch cluase
     */
    public override void visit_catch_clause (Vala.CatchClause clause) {
        indent();
        fout.printf("<catch>\n");
        level++;
        clause.accept_children(this);
        level--;
        indent();
        fout.printf("</catch>\n");
    }

    /**
     * Visit operation called for lock statements before the body has been visited.
     *
     * @param stmt a lock statement
     */
    public override void visit_lock_statement (Vala.LockStatement stmt) {
        indent();
        fout.printf("<lock>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</lock>\n");
    }

    /**
     * Visit operation called for unlock statements.
     *
     * @param stmt an unlock statement
     */
    public override void visit_unlock_statement (Vala.UnlockStatement stmt) {
        indent();
        fout.printf("<unlock>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</unlock>\n");
    }

    /**
     * Visit operation called for delete statements.
     *
     * @param stmt a delete statement
     */
    public override void visit_delete_statement (Vala.DeleteStatement stmt) {
        indent();
        fout.printf("<delete>\n");
        level++;
        stmt.accept_children(this);
        level--;
        indent();
        fout.printf("</delete>\n");
    }

    /**
     * Visit operations called for expresions.
     *
     * @param expr an expression
     */
    public override void visit_expression (Vala.Expression expr) {
        if (expr is Vala.MemberAccess || expr is Vala.Assignment) {
            return;
        }
        indent();
        fout.printf("<expression `%s`>\n", expr.to_string());
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</expression>\n");
    }

    /**
     * Visit operations called for array creation expresions.
     *
     * @param expr an array creation expression
     */
    public override void visit_array_creation_expression (Vala.ArrayCreationExpression expr) {
        indent();
        fout.printf("<array creation>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</array creation>\n");
    }

    /**
     * Visit operation called for boolean literals.
     *
     * @param lit a boolean literal
     */
    public override void visit_boolean_literal (Vala.BooleanLiteral lit) {
        indent();
        fout.printf("<boolean>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</boolean>\n");
    }

    /**
     * Visit operation called for character literals.
     *
     * @param lit a character literal
     */
    public override void visit_character_literal (Vala.CharacterLiteral lit) {
        indent();
        fout.printf("<character>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</character>\n");
    }

    /**
     * Visit operation called for integer literals.
     *
     * @param lit an integer literal
     */
    public override void visit_integer_literal (Vala.IntegerLiteral lit) {
        indent();
        fout.printf("<integer>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</integer>\n");
    }

    /**
     * Visit operation called for real literals.
     *
     * @param lit a real literal
     */
    public override void visit_real_literal (Vala.RealLiteral lit) {
        indent();
        fout.printf("<real>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</real>\n");
    }

    /**
     * Visit operation called for regex literals.
     *
     * @param lit a regex literal
     */
    public override void visit_regex_literal (Vala.RegexLiteral lit) {
        indent();
        fout.printf("<regex>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</regex>\n");
    }


    /**
     * Visit operation called for string literals.
     *
     * @param lit a string literal
     */
    public override void visit_string_literal (Vala.StringLiteral lit) {
        indent();
        fout.printf("<string>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</string>\n");
    }

    /**
     * Visit operation called for string templates.
     *
     * @param tmpl a string template
     */
    public override void visit_template (Vala.Template tmpl) {
        indent();
        fout.printf("<template>\n");
        level++;
        tmpl.accept_children(this);
        level--;
        indent();
        fout.printf("</template>\n");
    }

    /**
     * Visit operation called for tuples.
     *
     * @param tuple a tuple
     */
    public override void visit_tuple (Vala.Tuple tuple) {
        indent();
        fout.printf("<tuple>\n");
        level++;
        tuple.accept_children(this);
        level--;
        indent();
        fout.printf("</tuple>\n");
    }

    /**
     * Visit operation called for null literals.
     *
     * @param lit a null literal
     */
    public override void visit_null_literal (Vala.NullLiteral lit) {
        indent();
        fout.printf("<null>\n");
        level++;
        lit.accept_children(this);
        level--;
        indent();
        fout.printf("</null>\n");
    }

    /**
     * Visit operation called for member access expressions.
     *
     * @param expr a member access expression
     */
    public override void visit_member_access (Vala.MemberAccess expr) {
        indent();
        string name = "";
        if (expr.inner != null) {
            name += expr.inner.to_string() + ".";
        }
        name += expr.member_name;
        fout.printf("<member access %s>\n", name);
        indent();
        fout.printf("</member access %s>\n", name);
    }

    /**
     * Visit operation called for invocation expressions.
     *
     * @param expr an invocation expression
     */
    public override void visit_method_call (Vala.MethodCall expr) {
        indent();
        fout.printf("<call>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</call>\n");
    }

    /**
     * Visit operation called for element access expressions.
     *
     * @param expr an element access expression
     */
    public override void visit_element_access (Vala.ElementAccess expr) {
        indent();
        fout.printf("<element access>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</element access>\n");
    }

    /**
     * Visit operation called for array slice expressions.
     *
     * @param expr an array slice expression
     */
    public override void visit_slice_expression (Vala.SliceExpression expr) {
        indent();
        fout.printf("<slice>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</slice>\n");
    }

    /**
     * Visit operation called for base access expressions.
     *
     * @param expr a base access expression
     */
    public override void visit_base_access (Vala.BaseAccess expr) {
        indent();
        fout.printf("<base access>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</base access>\n");
    }

    /**
     * Visit operation called for postfix expressions.
     *
     * @param expr a postfix expression
     */
    public override void visit_postfix_expression (Vala.PostfixExpression expr) {
        indent();
        fout.printf("<postfix>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</postfix>\n");
    }

    /**
     * Visit operation called for object creation expressions.
     *
     * @param expr an object creation expression
     */
    public override void visit_object_creation_expression (Vala.ObjectCreationExpression expr) {
        indent();
        fout.printf("<object creation>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</object creation>\n");
    }

    /**
     * Visit operation called for sizeof expressions.
     *
     * @param expr a sizeof expression
     */
    public override void visit_sizeof_expression (Vala.SizeofExpression expr) {
        indent();
        fout.printf("<sizeof>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("<sizeof>\n");
    }

    /**
     * Visit operation called for typeof expressions.
     *
     * @param expr a typeof expression
     */
    public override void visit_typeof_expression (Vala.TypeofExpression expr) {
        indent();
        fout.printf("<typeof>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</typeof>\n");
    }

    /**
     * Visit operation called for unary expressions.
     *
     * @param expr an unary expression
     */
    public override void visit_unary_expression (Vala.UnaryExpression expr) {
        indent();
        fout.printf("<unary expr>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</unary expr>\n");
    }

    /**
     * Visit operation called for call expressions.
     *
     * @param expr a call expression
     */
    public override void visit_cast_expression (Vala.CastExpression expr) {
        indent();
        fout.printf("<cast>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</cast>\n");
    }

    /**
     * Visit operation called for named arguments.
     *
     * @param expr a named argument
     */
    public override void visit_named_argument (Vala.NamedArgument expr) {
        indent();
        fout.printf("<named arg>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</named arg>\n");
    }

    /**
     * Visit operation called for pointer indirections.
     *
     * @param expr a pointer indirection
     */
    public override void visit_pointer_indirection (Vala.PointerIndirection expr) {
        indent();
        fout.printf("<pointer indirection>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</pointer indirection>\n");
    }

    /**
     * Visit operation called for address-of expressions.
     *
     * @param expr an address-of expression
     */
    public override void visit_addressof_expression (Vala.AddressofExpression expr) {
        indent();
        fout.printf("<addressof>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</addressof>\n");
    }

    /**
     * Visit operation called for reference transfer expressions.
     *
     * @param expr a reference transfer expression
     */
    public override void visit_reference_transfer_expression (Vala.ReferenceTransferExpression expr) {
        indent();
        fout.printf("<ref transfer>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</ref transfer>\n");
    }

    /**
     * Visit operation called for binary expressions.
     *
     * @param expr a binary expression
     */
    public override void visit_binary_expression (Vala.BinaryExpression expr) {
        indent();
        fout.printf("<binary expr>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</binary expr>\n");
    }

    /**
     * Visit operation called for type checks.
     *
     * @param expr a type check expression
     */
    public override void visit_type_check (Vala.TypeCheck expr) {
        indent();
        fout.printf("<type check>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</type check>\n");
    }

    /**
     * Visit operation called for conditional expressions.
     *
     * @param expr a conditional expression
     */
    public override void visit_conditional_expression (Vala.ConditionalExpression expr) {
        indent();
        fout.printf("<conditional expr>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</conditional expr>\n");
    }

    /**
     * Visit operation called for lambda expressions.
     *
     * @param expr a lambda expression
     */
    public override void visit_lambda_expression (Vala.LambdaExpression expr) {
        indent();
        fout.printf("<lambda>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</lambda>\n");
    }

    /**
     * Visit operation called for assignments.
     *
     * @param a an assignment
     */
    public override void visit_assignment (Vala.Assignment a) {
        indent();
        fout.printf("<assignment>\n");
        level++;
        a.accept_children(this);
        level--;
        indent();
        fout.printf("</assignment>\n");
    }

    /**
     * Visit operation called at end of full expressions.
     *
     * @param expr a full expression
     */
    public override void visit_end_full_expression (Vala.Expression expr) {
        indent();
        fout.printf("<end full expr>\n");
        level++;
        expr.accept_children(this);
        level--;
        indent();
        fout.printf("</end full expr>\n");
    }
}
