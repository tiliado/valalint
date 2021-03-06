public class Linter.Config : KeyFile {
    public const string CHECKS = "Checks";
    public const string OPTIONS = "Options";

    public Config() {
        base();
    }

    public bool get_bool_or(string group, string key, bool default_value=false) {
        try {
            return get_boolean(group, key);
        } catch (GLib.KeyFileError e) {
            return default_value;
        }
    }

    public int get_int_or(string group, string key, int default_value=0) {
        try {
            return get_integer(group, key);
        } catch (GLib.KeyFileError e) {
            return default_value;
        }
    }

    public string? get_string_or(string group, string key, string? default_value=null) {
        try {
            return get_string(group, key);
        } catch (GLib.KeyFileError e) {
            return default_value;
        }
    }
}
