public class Linter.Rule : Vala.CodeVisitor {
    protected Vala.SourceFile current_file = null;
    protected Blocks current_blocks = null;
    protected TokenList current_tokens = null;

    public Rule() {
    }

    public virtual void setup(string param, string? value) {
    }

    public void apply(Vala.SourceFile file, TokenList tokens, Blocks blocks) {
        current_file = file;
        current_blocks = blocks;
        current_tokens = tokens;
        visit_tokens(tokens);
        visit_source_file(file);
        current_file = null;
        current_blocks = null;
        current_tokens = null;
    }

    public void error(Vala.SourceLocation begin, Vala.SourceLocation end, string message, ...) {
        if (begin.line != end.line) {
            begin = end;
            begin.column = 0;
            begin.pos = end.pos - end.column;
        }
        Vala.Report.error(
            new Vala.SourceReference(current_file, begin, end), message.vprintf(va_list()));
    }

    public void notice(Vala.SourceLocation begin, Vala.SourceLocation end, string message, ...) {
        Vala.Report.notice(
            new Vala.SourceReference(current_file, begin, end), message.vprintf(va_list()));
    }

    public virtual void visit_tokens(TokenList tokens) {
    }

    public override void visit_source_file(Vala.SourceFile file) {
        file.accept_children(this);
    }

    /**
     * Visit operation called for namespaces.
     *
     * @param ns a namespace
     */
    public override void visit_namespace (Vala.Namespace ns) {
        ns.accept_children(this);
    }

    /**
     * Visit operation called for classes.
     *
     * @param cl a class
     */
    public override void visit_class (Vala.Class cl) {
        cl.accept_children(this);
    }

    /**
     * Visit operation called for structs.
     *
     * @param st a struct
     */
    public override void visit_struct (Vala.Struct st) {
        st.accept_children(this);
    }

    /**
     * Visit operation called for interfaces.
     *
     * @param iface an interface
     */
    public override void visit_interface (Vala.Interface iface) {
        iface.accept_children(this);
    }

    /**
     * Visit operation called for enums.
     *
     * @param en an enum
     */
    public override void visit_enum (Vala.Enum en) {
        en.accept_children(this);
    }

    /**
     * Visit operation called for enum values.
     *
     * @param ev an enum value
     */
    public override void visit_enum_value (Vala.EnumValue ev) {
        ev.accept_children(this);
    }

    /**
     * Visit operation called for error domains.
     *
     * @param edomain an error domain
     */
    public override void visit_error_domain (Vala.ErrorDomain edomain) {
        edomain.accept_children(this);
    }

    /**
     * Visit operation called for error codes.
     *
     * @param ecode an error code
     */
    public override void visit_error_code (Vala.ErrorCode ecode) {
        ecode.accept_children(this);
    }

    /**
     * Visit operation called for delegates.
     *
     * @param d a delegate
     */
    public override void visit_delegate (Vala.Delegate d) {
        d.accept_children(this);
    }

    /**
     * Visit operation called for constants.
     *
     * @param c a constant
     */
    public override void visit_constant (Vala.Constant c) {
        c.accept_children(this);
    }

    /**
     * Visit operation called for fields.
     *
     * @param f a field
     */
    public override void visit_field (Vala.Field f) {
        f.accept_children(this);
    }

    /**
     * Visit operation called for methods.
     *
     * @param m a method
     */
    public override void visit_method (Vala.Method m) {
        m.accept_children(this);
    }

    /**
     * Visit operation called for creation methods.
     *
     * @param m a method
     */
    public override void visit_creation_method (Vala.CreationMethod m) {
        m.accept_children(this);
    }

    /**
     * Visit operation called for formal parameters.
     *
     * @param p a formal parameter
     */
    public override void visit_formal_parameter (Vala.Parameter p) {
        p.accept_children(this);
    }

    /**
     * Visit operation called for properties.
     *
     * @param prop a property
     */
    public override void visit_property (Vala.Property prop) {
        prop.accept_children(this);
    }

    /**
     * Visit operation called for property accessors.
     *
     * @param acc a property accessor
     */
    public override void visit_property_accessor (Vala.PropertyAccessor acc) {
        acc.accept_children(this);
    }

    /**
     * Visit operation called for signals.
     *
     * @param sig a signal
     */
    public override void visit_signal (Vala.Signal sig) {
        sig.accept_children(this);
    }

    /**
     * Visit operation called for constructors.
     *
     * @param c a constructor
     */
    public override void visit_constructor (Vala.Constructor c) {
        c.accept_children(this);
    }

    /**
     * Visit operation called for destructors.
     *
     * @param d a destructor
     */
    public override void visit_destructor (Vala.Destructor d) {
        d.accept_children(this);
    }

    /**
     * Visit operation called for type parameters.
     *
     * @param p a type parameter
     */
    public override void visit_type_parameter (Vala.TypeParameter p) {
        p.accept_children(this);
    }

    /**
     * Visit operation called for using directives.
     *
     * @param ns a using directive
     */
    public override void visit_using_directive (Vala.UsingDirective ns) {
        ns.accept_children(this);
    }

    /**
     * Visit operation called for type references.
     *
     * @param type a type reference
     */
    public override void visit_data_type (Vala.DataType type) {
        type.accept_children(this);
    }

    /**
     * Visit operation called for blocks.
     *
     * @param b a block
     */
    public override void visit_block (Vala.Block b) {
        b.accept_children(this);
    }

    /**
     * Visit operation called for empty statements.
     *
     * @param stmt an empty statement
     */
    public override void visit_empty_statement (Vala.EmptyStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for declaration statements.
     *
     * @param stmt a declaration statement
     */
    public override void visit_declaration_statement (Vala.DeclarationStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for local variables.
     *
     * @param local a local variable
     */
    public override void visit_local_variable (Vala.LocalVariable local) {
        local.accept_children(this);
    }

    /**
     * Visit operation called for initializer lists
     *
     * @param list an initializer list
     */
    public override void visit_initializer_list (Vala.InitializerList list) {
        list.accept_children(this);
    }

    /**
     * Visit operation called for expression statements.
     *
     * @param stmt an expression statement
     */
    public override void visit_expression_statement (Vala.ExpressionStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for if statements.
     *
     * @param stmt an if statement
     */
    public override void visit_if_statement (Vala.IfStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for switch statements.
     *
     * @param stmt a switch statement
     */
    public override void visit_switch_statement (Vala.SwitchStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for switch sections.
     *
     * @param section a switch section
     */
    public override void visit_switch_section (Vala.SwitchSection section) {
        section.accept_children(this);
    }

    /**
     * Visit operation called for switch label.
     *
     * @param label a switch label
     */
    public override void visit_switch_label (Vala.SwitchLabel label) {
        label.accept_children(this);
    }

    /**
     * Visit operation called for loops.
     *
     * @param stmt a loop
     */
    public override void visit_loop (Vala.Loop stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for while statements.
     *
     * @param stmt an while statement
     */
    public override void visit_while_statement (Vala.WhileStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for do statements.
     *
     * @param stmt a do statement
     */
    public override void visit_do_statement (Vala.DoStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for for statements.
     *
     * @param stmt a for statement
     */
    public override void visit_for_statement (Vala.ForStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for foreach statements.
     *
     * @param stmt a foreach statement
     */
    public override void visit_foreach_statement (Vala.ForeachStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for break statements.
     *
     * @param stmt a break statement
     */
    public override void visit_break_statement (Vala.BreakStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for continue statements.
     *
     * @param stmt a continue statement
     */
    public override void visit_continue_statement (Vala.ContinueStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for return statements.
     *
     * @param stmt a return statement
     */
    public override void visit_return_statement (Vala.ReturnStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for yield statement.
     *
     * @param y a yield statement
     */
    public override void visit_yield_statement (Vala.YieldStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for throw statements.
     *
     * @param stmt a throw statement
     */
    public override void visit_throw_statement (Vala.ThrowStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for try statements.
     *
     * @param stmt a try statement
     */
    public override void visit_try_statement (Vala.TryStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for catch clauses.
     *
     * @param clause a catch cluase
     */
    public override void visit_catch_clause (Vala.CatchClause clause) {
    }

    /**
     * Visit operation called for lock statements before the body has been visited.
     *
     * @param stmt a lock statement
     */
    public override void visit_lock_statement (Vala.LockStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for unlock statements.
     *
     * @param stmt an unlock statement
     */
    public override void visit_unlock_statement (Vala.UnlockStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operation called for delete statements.
     *
     * @param stmt a delete statement
     */
    public override void visit_delete_statement (Vala.DeleteStatement stmt) {
        stmt.accept_children(this);
    }

    /**
     * Visit operations called for expresions.
     *
     * @param expr an expression
     */
    public override void visit_expression (Vala.Expression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operations called for array creation expresions.
     *
     * @param expr an array creation expression
     */
    public override void visit_array_creation_expression (Vala.ArrayCreationExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for boolean literals.
     *
     * @param lit a boolean literal
     */
    public override void visit_boolean_literal (Vala.BooleanLiteral lit) {
        lit.accept_children(this);
    }

    /**
     * Visit operation called for character literals.
     *
     * @param lit a character literal
     */
    public override void visit_character_literal (Vala.CharacterLiteral lit) {
        lit.accept_children(this);
    }

    /**
     * Visit operation called for integer literals.
     *
     * @param lit an integer literal
     */
    public override void visit_integer_literal (Vala.IntegerLiteral lit) {
        lit.accept_children(this);
    }

    /**
     * Visit operation called for real literals.
     *
     * @param lit a real literal
     */
    public override void visit_real_literal (Vala.RealLiteral lit) {
        lit.accept_children(this);
    }

    /**
     * Visit operation called for regex literals.
     *
     * @param lit a regex literal
     */
    public override void visit_regex_literal (Vala.RegexLiteral lit) {
        lit.accept_children(this);
    }


    /**
     * Visit operation called for string literals.
     *
     * @param lit a string literal
     */
    public override void visit_string_literal (Vala.StringLiteral lit) {
        lit.accept_children(this);
    }

    /**
     * Visit operation called for string templates.
     *
     * @param tmpl a string template
     */
    public override void visit_template (Vala.Template tmpl) {
        tmpl.accept_children(this);
    }

    /**
     * Visit operation called for tuples.
     *
     * @param tuple a tuple
     */
    public override void visit_tuple (Vala.Tuple tuple) {
        tuple.accept_children(this);
    }

    /**
     * Visit operation called for null literals.
     *
     * @param lit a null literal
     */
    public override void visit_null_literal (Vala.NullLiteral lit) {
        lit.accept_children(this);
    }

    /**
     * Visit operation called for member access expressions.
     *
     * @param expr a member access expression
     */
    public override void visit_member_access (Vala.MemberAccess expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for invocation expressions.
     *
     * @param expr an invocation expression
     */
    public override void visit_method_call (Vala.MethodCall expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for element access expressions.
     *
     * @param expr an element access expression
     */
    public override void visit_element_access (Vala.ElementAccess expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for array slice expressions.
     *
     * @param expr an array slice expression
     */
    public override void visit_slice_expression (Vala.SliceExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for base access expressions.
     *
     * @param expr a base access expression
     */
    public override void visit_base_access (Vala.BaseAccess expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for postfix expressions.
     *
     * @param expr a postfix expression
     */
    public override void visit_postfix_expression (Vala.PostfixExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for object creation expressions.
     *
     * @param expr an object creation expression
     */
    public override void visit_object_creation_expression (Vala.ObjectCreationExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for sizeof expressions.
     *
     * @param expr a sizeof expression
     */
    public override void visit_sizeof_expression (Vala.SizeofExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for typeof expressions.
     *
     * @param expr a typeof expression
     */
    public override void visit_typeof_expression (Vala.TypeofExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for unary expressions.
     *
     * @param expr an unary expression
     */
    public override void visit_unary_expression (Vala.UnaryExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for call expressions.
     *
     * @param expr a call expression
     */
    public override void visit_cast_expression (Vala.CastExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for named arguments.
     *
     * @param expr a named argument
     */
    public override void visit_named_argument (Vala.NamedArgument expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for pointer indirections.
     *
     * @param expr a pointer indirection
     */
    public override void visit_pointer_indirection (Vala.PointerIndirection expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for address-of expressions.
     *
     * @param expr an address-of expression
     */
    public override void visit_addressof_expression (Vala.AddressofExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for reference transfer expressions.
     *
     * @param expr a reference transfer expression
     */
    public override void visit_reference_transfer_expression (Vala.ReferenceTransferExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for binary expressions.
     *
     * @param expr a binary expression
     */
    public override void visit_binary_expression (Vala.BinaryExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for type checks.
     *
     * @param expr a type check expression
     */
    public override void visit_type_check (Vala.TypeCheck expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for conditional expressions.
     *
     * @param expr a conditional expression
     */
    public override void visit_conditional_expression (Vala.ConditionalExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for lambda expressions.
     *
     * @param expr a lambda expression
     */
    public override void visit_lambda_expression (Vala.LambdaExpression expr) {
        expr.accept_children(this);
    }

    /**
     * Visit operation called for assignments.
     *
     * @param a an assignment
     */
    public override void visit_assignment (Vala.Assignment a) {
        a.accept_children(this);
    }

    /**
     * Visit operation called at end of full expressions.
     *
     * @param expr a full expression
     */
    public override void visit_end_full_expression (Vala.Expression expr) {
        expr.accept_children(this);
    }
}
