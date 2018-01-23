public class Linter.Rule {
    protected Vala.SourceFile current_file = null;
    protected Blocks current_blocks = null;
    protected TokenList current_tokens = null;
    public Vala.List<Fix> fixes = new Vala.ArrayList<Fix>();
    public bool fix_errors = false;

    public Rule() {
    }

    public virtual void setup(Config config) {
        fix_errors = config.get_bool_or(Config.OPTIONS, "fix_errors");
    }

    public void apply(Vala.SourceFile file, TokenList tokens, Blocks blocks) {
        current_file = file;
        current_blocks = blocks;
        current_tokens = tokens;
        lint_tokens(tokens);
    }

    public void reset() {
        current_file = null;
        current_blocks = null;
        current_tokens = null;
    }

    public Fix fix(char* begin, char* end, owned string? replacement) {
        var fix = new Fix(current_file, begin, end, (owned) replacement);
        fixes.add(fix);
        return fix;
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

    public virtual void lint_tokens(TokenList tokens) {
    }

    public virtual void lint_source_file(Vala.SourceFile file) {
    }

    /**
     * Visit operation called for classes.
     *
     * @param cl a class
     */
    public virtual void lint_class (Vala.Class cl) {
    }

    /**
     * Visit operation called for structs.
     *
     * @param st a struct
     */
    public virtual void lint_struct (Vala.Struct st) {
    }

    /**
     * Visit operation called for interfaces.
     *
     * @param iface an interface
     */
    public virtual void lint_interface (Vala.Interface iface) {
    }

    /**
     * Visit operation called for enums.
     *
     * @param en an enum
     */
    public virtual void lint_enum (Vala.Enum en) {
    }

    /**
     * Visit operation called for enum values.
     *
     * @param ev an enum value
     */
    public virtual void lint_enum_value (Vala.EnumValue ev) {
    }

    /**
     * Visit operation called for error domains.
     *
     * @param edomain an error domain
     */
    public virtual void lint_error_domain (Vala.ErrorDomain edomain) {
    }

    /**
     * Visit operation called for error codes.
     *
     * @param ecode an error code
     */
    public virtual void lint_error_code (Vala.ErrorCode ecode) {
    }

    /**
     * Visit operation called for delegates.
     *
     * @param d a delegate
     */
    public virtual void lint_delegate (Vala.Delegate d) {
    }

    /**
     * Visit operation called for constants.
     *
     * @param c a constant
     */
    public virtual void lint_constant (Vala.Constant c) {
    }

    /**
     * Visit operation called for fields.
     *
     * @param f a field
     */
    public virtual void lint_field (Vala.Field f) {
    }

    /**
     * Visit operation called for methods.
     *
     * @param m a method
     */
    public virtual void lint_method (Vala.Method m) {
    }

    /**
     * Visit operation called for creation methods.
     *
     * @param m a method
     */
    public virtual void lint_creation_method (Vala.CreationMethod m) {
    }

    /**
     * Visit operation called for formal parameters.
     *
     * @param p a formal parameter
     */
    public virtual void lint_formal_parameter (Vala.Parameter p) {
    }

    /**
     * Visit operation called for properties.
     *
     * @param prop a property
     */
    public virtual void lint_property (Vala.Property prop) {
    }

    /**
     * Visit operation called for property accessors.
     *
     * @param acc a property accessor
     */
    public virtual void lint_property_accessor (Vala.PropertyAccessor acc) {
    }

    /**
     * Visit operation called for signals.
     *
     * @param sig a signal
     */
    public virtual void lint_signal (Vala.Signal sig) {
    }

    /**
     * Visit operation called for constructors.
     *
     * @param c a constructor
     */
    public virtual void lint_constructor (Vala.Constructor c) {
    }

    /**
     * Visit operation called for destructors.
     *
     * @param d a destructor
     */
    public virtual void lint_destructor (Vala.Destructor d) {
    }

    /**
     * Visit operation called for type parameters.
     *
     * @param p a type parameter
     */
    public virtual void lint_type_parameter (Vala.TypeParameter p) {
    }

    /**
     * Visit operation called for using directives.
     *
     * @param ns a using directive
     */
    public virtual void lint_using_directive (Vala.UsingDirective ns) {
    }

    /**
     * Visit operation called for type references.
     *
     * @param type a type reference
     */
    public virtual void lint_data_type (Vala.DataType type) {
    }

    /**
     * Visit operation called for blocks.
     *
     * @param b a block
     */
    public virtual void lint_block (Vala.Block b) {
    }

    /**
     * Visit operation called for empty statements.
     *
     * @param stmt an empty statement
     */
    public virtual void lint_empty_statement (Vala.EmptyStatement stmt) {
    }

    /**
     * Visit operation called for declaration statements.
     *
     * @param stmt a declaration statement
     */
    public virtual void lint_declaration_statement (Vala.DeclarationStatement stmt) {
    }

    /**
     * Visit operation called for local variables.
     *
     * @param local a local variable
     */
    public virtual void lint_local_variable (Vala.LocalVariable local) {
    }

    /**
     * Visit operation called for initializer lists
     *
     * @param list an initializer list
     */
    public virtual void lint_initializer_list (Vala.InitializerList list) {
    }

    /**
     * Visit operation called for expression statements.
     *
     * @param stmt an expression statement
     */
    public virtual void lint_expression_statement (Vala.ExpressionStatement stmt) {
    }

    /**
     * Visit operation called for if statements.
     *
     * @param stmt an if statement
     */
    public virtual void lint_if_statement (Vala.IfStatement stmt) {
    }

    /**
     * Visit operation called for switch statements.
     *
     * @param stmt a switch statement
     */
    public virtual void lint_switch_statement (Vala.SwitchStatement stmt) {
    }

    /**
     * Visit operation called for switch sections.
     *
     * @param section a switch section
     */
    public virtual void lint_switch_section (Vala.SwitchSection section) {
    }

    /**
     * Visit operation called for switch label.
     *
     * @param label a switch label
     */
    public virtual void lint_switch_label (Vala.SwitchLabel label) {
    }

    /**
     * Visit operation called for loops.
     *
     * @param stmt a loop
     */
    public virtual void lint_loop (Vala.Loop stmt) {
    }

    /**
     * Visit operation called for while statements.
     *
     * @param stmt an while statement
     */
    public virtual void lint_while_statement (Vala.WhileStatement stmt) {
    }

    /**
     * Visit operation called for do statements.
     *
     * @param stmt a do statement
     */
    public virtual void lint_do_statement (Vala.DoStatement stmt) {
    }

    /**
     * Visit operation called for for statements.
     *
     * @param stmt a for statement
     */
    public virtual void lint_for_statement (Vala.ForStatement stmt) {
    }

    /**
     * Visit operation called for foreach statements.
     *
     * @param stmt a foreach statement
     */
    public virtual void lint_foreach_statement (Vala.ForeachStatement stmt) {
    }

    /**
     * Visit operation called for break statements.
     *
     * @param stmt a break statement
     */
    public virtual void lint_break_statement (Vala.BreakStatement stmt) {
    }

    /**
     * Visit operation called for continue statements.
     *
     * @param stmt a continue statement
     */
    public virtual void lint_continue_statement (Vala.ContinueStatement stmt) {
    }

    /**
     * Visit operation called for return statements.
     *
     * @param stmt a return statement
     */
    public virtual void lint_return_statement (Vala.ReturnStatement stmt) {
    }

    /**
     * Visit operation called for yield statement.
     *
     * @param y a yield statement
     */
    public virtual void lint_yield_statement (Vala.YieldStatement stmt) {
    }

    /**
     * Visit operation called for throw statements.
     *
     * @param stmt a throw statement
     */
    public virtual void lint_throw_statement (Vala.ThrowStatement stmt) {
    }

    /**
     * Visit operation called for try statements.
     *
     * @param stmt a try statement
     */
    public virtual void lint_try_statement (Vala.TryStatement stmt) {
    }

    /**
     * Visit operation called for catch clauses.
     *
     * @param clause a catch cluase
     */
    public virtual void lint_catch_clause (Vala.CatchClause clause) {
    }

    /**
     * Visit operation called for lock statements before the body has been visited.
     *
     * @param stmt a lock statement
     */
    public virtual void lint_lock_statement (Vala.LockStatement stmt) {
    }

    /**
     * Visit operation called for unlock statements.
     *
     * @param stmt an unlock statement
     */
    public virtual void lint_unlock_statement (Vala.UnlockStatement stmt) {
    }

    /**
     * Visit operation called for delete statements.
     *
     * @param stmt a delete statement
     */
    public virtual void lint_delete_statement (Vala.DeleteStatement stmt) {
    }

    /**
     * Visit operations called for expresions.
     *
     * @param expr an expression
     */
    public virtual void lint_expression (Vala.Expression expr) {
    }

    /**
     * Visit operations called for array creation expresions.
     *
     * @param expr an array creation expression
     */
    public virtual void lint_array_creation_expression (Vala.ArrayCreationExpression expr) {
    }

    /**
     * Visit operation called for boolean literals.
     *
     * @param lit a boolean literal
     */
    public virtual void lint_boolean_literal (Vala.BooleanLiteral lit) {
    }

    /**
     * Visit operation called for character literals.
     *
     * @param lit a character literal
     */
    public virtual void lint_character_literal (Vala.CharacterLiteral lit) {
    }

    /**
     * Visit operation called for integer literals.
     *
     * @param lit an integer literal
     */
    public virtual void lint_integer_literal (Vala.IntegerLiteral lit) {
    }

    /**
     * Visit operation called for real literals.
     *
     * @param lit a real literal
     */
    public virtual void lint_real_literal (Vala.RealLiteral lit) {
    }

    /**
     * Visit operation called for regex literals.
     *
     * @param lit a regex literal
     */
    public virtual void lint_regex_literal (Vala.RegexLiteral lit) {
    }


    /**
     * Visit operation called for string literals.
     *
     * @param lit a string literal
     */
    public virtual void lint_string_literal (Vala.StringLiteral lit) {
    }

    /**
     * Visit operation called for string templates.
     *
     * @param tmpl a string template
     */
    public virtual void lint_template (Vala.Template tmpl) {
    }

    /**
     * Visit operation called for tuples.
     *
     * @param tuple a tuple
     */
    public virtual void lint_tuple (Vala.Tuple tuple) {
    }

    /**
     * Visit operation called for null literals.
     *
     * @param lit a null literal
     */
    public virtual void lint_null_literal (Vala.NullLiteral lit) {
    }

    /**
     * Visit operation called for member access expressions.
     *
     * @param expr a member access expression
     */
    public virtual void lint_member_access (Vala.MemberAccess expr) {
    }

    /**
     * Visit operation called for invocation expressions.
     *
     * @param expr an invocation expression
     */
    public virtual void lint_method_call (Vala.MethodCall expr) {
    }

    /**
     * Visit operation called for element access expressions.
     *
     * @param expr an element access expression
     */
    public virtual void lint_element_access (Vala.ElementAccess expr) {
    }

    /**
     * Visit operation called for array slice expressions.
     *
     * @param expr an array slice expression
     */
    public virtual void lint_slice_expression (Vala.SliceExpression expr) {
    }

    /**
     * Visit operation called for base access expressions.
     *
     * @param expr a base access expression
     */
    public virtual void lint_base_access (Vala.BaseAccess expr) {
    }

    /**
     * Visit operation called for postfix expressions.
     *
     * @param expr a postfix expression
     */
    public virtual void lint_postfix_expression (Vala.PostfixExpression expr) {
    }

    /**
     * Visit operation called for object creation expressions.
     *
     * @param expr an object creation expression
     */
    public virtual void lint_object_creation_expression (Vala.ObjectCreationExpression expr) {
    }

    /**
     * Visit operation called for sizeof expressions.
     *
     * @param expr a sizeof expression
     */
    public virtual void lint_sizeof_expression (Vala.SizeofExpression expr) {
    }

    /**
     * Visit operation called for typeof expressions.
     *
     * @param expr a typeof expression
     */
    public virtual void lint_typeof_expression (Vala.TypeofExpression expr) {
    }

    /**
     * Visit operation called for unary expressions.
     *
     * @param expr an unary expression
     */
    public virtual void lint_unary_expression (Vala.UnaryExpression expr) {
    }

    /**
     * Visit operation called for call expressions.
     *
     * @param expr a call expression
     */
    public virtual void lint_cast_expression (Vala.CastExpression expr) {
    }

    /**
     * Visit operation called for named arguments.
     *
     * @param expr a named argument
     */
    public virtual void lint_named_argument (Vala.NamedArgument expr) {
    }

    /**
     * Visit operation called for pointer indirections.
     *
     * @param expr a pointer indirection
     */
    public virtual void lint_pointer_indirection (Vala.PointerIndirection expr) {
    }

    /**
     * Visit operation called for address-of expressions.
     *
     * @param expr an address-of expression
     */
    public virtual void lint_addressof_expression (Vala.AddressofExpression expr) {
    }

    /**
     * Visit operation called for reference transfer expressions.
     *
     * @param expr a reference transfer expression
     */
    public virtual void lint_reference_transfer_expression (Vala.ReferenceTransferExpression expr) {
    }

    /**
     * Visit operation called for binary expressions.
     *
     * @param expr a binary expression
     */
    public virtual void lint_binary_expression (Vala.BinaryExpression expr) {
    }

    /**
     * Visit operation called for type checks.
     *
     * @param expr a type check expression
     */
    public virtual void lint_type_check (Vala.TypeCheck expr) {
    }

    /**
     * Visit operation called for conditional expressions.
     *
     * @param expr a conditional expression
     */
    public virtual void lint_conditional_expression (Vala.ConditionalExpression expr) {
    }

    /**
     * Visit operation called for lambda expressions.
     *
     * @param expr a lambda expression
     */
    public virtual void lint_lambda_expression (Vala.LambdaExpression expr) {
    }

    /**
     * Visit operation called for assignments.
     *
     * @param a an assignment
     */
    public virtual void lint_assignment (Vala.Assignment a) {
    }

    /**
     * Visit operation called at end of full expressions.
     *
     * @param expr a full expression
     */
    public virtual void lint_end_full_expression (Vala.Expression expr) {
    }
}
