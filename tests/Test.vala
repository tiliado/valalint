private const string STDOUT_FAILED_WITH_FIXES = """Vala lint failed: %d error(s), %d warning(s)
Lint auto fix succeeded: %d fix(es) applied.
Some errors were fixed by auto fix. Run valalint again to get up-to-date results.
""";

public class Linter.TestCase {
    public string name;
    public string vala_file;
    public string stderr_file;
    public string fixed_file;
    public string config_file;
    public KeyFile config;
    public int n_errors = 0;
    public int n_warnings = 0;
    public int n_applied_fixes = 0;
    public int n_failed_fixes = 0;
    public bool has_checks_config = false;

    public TestCase(string name) {
        this.name = name.replace(".", "/");
        if (!this.name.has_prefix("/")) {
            this.name = "/" + this.name;
        }
        this.vala_file = name + ".vala";
        this.stderr_file = name + ".stderr";
        this.fixed_file = name + ".fixed";
        this.config_file = name + ".conf";
        this.config = new KeyFile();
        try {
            config.load_from_file(this.config_file, KeyFileFlags.NONE);
            has_checks_config = config.has_group("Checks");
            n_errors = config.get_integer("Result", "errors");
            n_warnings = config.get_integer("Result", "warnings");
            n_applied_fixes = config.get_integer("Result", "applied_fixes");
            n_failed_fixes = config.get_integer("Result", "failed_fixes");
        } catch (GLib.Error e) {
            warning("Failed to load config '%s'. %s", name + ".conf", e.message);
        }
    }

    public void run() {
        string test_dir = "build/test";
        if (!FileUtils.test(test_dir, FileTest.IS_DIR)) {
            if (!FileUtils.test("build", FileTest.IS_DIR)) {
                assert(DirUtils.create("build", 0755) == 0);
            }
            assert(DirUtils.create(test_dir, 0755) == 0);
        }

        string test_file = Path.build_filename(test_dir, "test.vala");
        uint8[] data;
        try {
            FileUtils.get_data(this.vala_file, out data);
            FileUtils.set_data(test_file, data);
        } catch (GLib.FileError e) {
            Test.message("%s: Failed to copy Vala file. %s.", name, e.message);
            Test.fail();
            return;
        }

        string? stdout_buf = null;
        string? stderr_buf = null;
        try {
            lint(test_file, null, out stdout_buf, out stderr_buf);
        } catch (GLib.Error e) {
            Test.message("%s: Failed to lint file. %s.", name, e.message);
            Test.fail();
            return;
        }

        string stdout_test_path = Path.build_filename(test_dir, "test.stdout");
        try {
            FileUtils.set_contents(stdout_test_path, stdout_buf ?? "");
        } catch (FileError e) {
            Test.message("%s: I/O error. %s.", name, e.message);
            Test.fail();
        }
        string stderr_test_path = Path.build_filename(test_dir, "test.stderr");
        try {
            FileUtils.set_contents(stderr_test_path, stderr_buf ?? "");
        } catch (FileError e) {
            Test.message("%s: I/O error. %s.", name, e.message);
            Test.fail();
        }

        string? expected_stdout;
        if (n_errors + n_warnings == 0) {
            expected_stdout = "";
        } else {
            expected_stdout = STDOUT_FAILED_WITH_FIXES.printf(n_errors, n_warnings, n_applied_fixes);
        }

        string expected_stdout_path = Path.build_filename(test_dir, "test.stdout.expected");
        try {

            if (expected_stdout != stdout_buf) {
                Test.message("%s: stdout differs - see %s.diff", name, stdout_test_path);
                Test.fail();
                FileUtils.set_contents(expected_stdout_path, expected_stdout);
                FileUtils.set_contents(stdout_test_path + ".diff", diff(expected_stdout_path, stdout_test_path) ?? "");
            }
        } catch (Error e) {
            Test.message("%s: I/O error. %s.", name, e.message);
            Test.fail();
        }

        if (FileUtils.test(stderr_file, FileTest.IS_REGULAR)) {
            try {
                string? expected_stderr = null;
                FileUtils.get_contents(stderr_file, out expected_stderr);
                if (expected_stderr != stderr_buf) {
                    Test.message("%s: stderr differs - see %s.diff", name, stderr_test_path);
                    Test.fail();
                    FileUtils.set_contents(stderr_test_path + ".diff", diff(stderr_file, stderr_test_path) ?? "");
                }
            } catch (Error e) {
                Test.message("%s: I/O error. %s.", name, e.message);
                Test.fail();
            }
        }

        if (FileUtils.test(fixed_file, FileTest.IS_REGULAR)) {
            try {
                string? expected_fixed = null;
                FileUtils.get_contents(fixed_file, out expected_fixed);
                string? actual_fixed = null;
                FileUtils.get_contents(test_file, out actual_fixed);
                if (expected_fixed != actual_fixed) {
                    Test.message("%s: source differs - see %s.diff", name, test_file);
                    Test.fail();
                    FileUtils.set_contents(test_file + ".diff", diff(fixed_file, test_file) ?? "");
                }
            } catch (Error e) {
                Test.message("%s: I/O error. %s.", name, e.message);
                Test.fail();
            }
        }
    }

    private void lint(string path, out int ret_code, out string? stdout_buf, out string? stderr_buf) throws Error {
        var linter = new GLib.Subprocess(
            SubprocessFlags.STDOUT_PIPE|SubprocessFlags.STDERR_PIPE,
            "build/valalint", "-C", has_checks_config ? this.config_file : ".valalint.conf", "--fix", path, null);
        linter.communicate_utf8(null, null, out stdout_buf, out stderr_buf);
        assert(linter.get_if_exited());
        ret_code = linter.get_exit_status();
    }

    private string? diff(string old_path, string new_path) throws Error {
        string? result = null;
        var diff = new GLib.Subprocess(
            SubprocessFlags.STDOUT_PIPE|SubprocessFlags.STDERR_MERGE,
            "diff", "-u", old_path, new_path, null);
        diff.communicate_utf8(null, null, out result, null);
        assert(diff.get_if_exited());
        return result;
    }

    static int main(string[] argv) {
        Test.init(ref argv);
        try {
            lookup_tests("tests");
        } catch (GLib.FileError e) {
            stderr.printf("Failed to create test cases. %s.\n", e.message);
        }
        return Test.run();
    }

    static void lookup_tests(string directory) throws FileError {
        Dir dir = Dir.open(directory, 0);
        string? name = null;
        while ((name = dir.read_name()) != null) {
            string path = Path.build_filename(directory, name);
            if (name.has_suffix(".vala") && FileUtils.test(path, FileTest.IS_REGULAR)) {
                var test = new TestCase(path.substring(0, path.length - 5));
                Test.add_data_func(test.name, test.run);
            } else if (FileUtils.test(path, FileTest.IS_DIR)) {
                lookup_tests(path);
            }
        }
    }
}
