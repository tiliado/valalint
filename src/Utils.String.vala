namespace Linter.Utils.String {

public inline bool is_whitespace(string? str) {
    return Utils.Buffer.is_whitespace((char*) str, null);
}

} // namespace Linter.Utils.String
