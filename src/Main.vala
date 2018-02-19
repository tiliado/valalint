class Linter.Main {
    [CCode (cname="VALALINT_VERSION")]
    private extern const string VERSION;
    private const string DEFAULT_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";

    static string basedir;
    static string directory;
    static string config_file;
    static bool version;
    static bool dump_tree;
    static bool fix_errors;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] sources;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] checks;
    static bool no_default_config_file;
    static bool disable_assert;
    static bool experimental;
    static bool experimental_non_null;
    static bool disable_warnings;
    static bool quiet_mode;
    static bool verbose_mode;
    static bool fatal_warnings;
    static bool disable_diagnostic_colors;
    static bool run_output = true;
    private Vala.CodeContext context;

    const OptionEntry[] options = {
        {
            "check", 'c', 0, OptionArg.STRING_ARRAY, ref checks,
            "What linter checks to enable", "CHECK_NAME..."
        }, {
            "config", 'C', 0, OptionArg.FILENAME, ref config_file,
            "Configuration file", "PATH"
        }, {
            "no-default-config", 0, 0, OptionArg.NONE, ref no_default_config_file,
            "Don't load default configuration file .valalint.conf.", null
        }, {
            "basedir", 'b', 0, OptionArg.FILENAME, ref basedir,
            "Base source directory", "DIRECTORY"
        }, {
            "fix", 0, 0, OptionArg.NONE, ref fix_errors,
            "Fix errors. Experimental!", null
        }, {
            "version", 0, 0, OptionArg.NONE, ref version,
            "Display version number", null
        }, {
            "dump-tree", 0, 0, OptionArg.NONE, ref dump_tree,
            "Dump code visitor tree.", null
        }, {
            "enable-experimental", 0, 0, OptionArg.NONE, ref experimental,
            "Enable experimental features", null
        }, {
            "enable-experimental-non-null", 0, 0, OptionArg.NONE, ref experimental_non_null,
            "Enable experimental enhancements for non-null types", null
        }, {
            "quiet", 'q', 0, OptionArg.NONE, ref quiet_mode,
            "Do not print messages to the console", null
        }, {
            "verbose", 'v', 0, OptionArg.NONE, ref verbose_mode,
            "Print additional messages to the console", null
        }, {
            "no-color", 0, 0, OptionArg.NONE, ref disable_diagnostic_colors,
            "Disable colored output", null
        }, {
            "", 0, 0, OptionArg.FILENAME_ARRAY, ref sources, null, "FILE..."
        }, {
            null
        }
    };

    private int quit(Fixer? fixer=null) {
        if (context.report.get_errors() == 0 && context.report.get_warnings() == 0) {
            return 0;
        }
        if (context.report.get_errors() == 0 && (!fatal_warnings || context.report.get_warnings() == 0)) {
            if (!quiet_mode) {
                stdout.printf(
                    "Vala lint succeeded - %d warning(s)\n", context.report.get_warnings());
            }
            return 0;
        } else {
            if (!quiet_mode) {
                stdout.printf(
                    "Vala lint failed: %d error(s), %d warning(s)\n",
                    context.report.get_errors(), context.report.get_warnings());
                if (fixer != null && fixer.n_applied_fixes + fixer.n_failed_fixes > 0) {
                    if (fixer.n_failed_fixes > 0) {
                        stdout.printf(
                            "Lint auto fix failed: %d fix(es) failed, %d fix(es) applied.\n",
                            fixer.n_failed_fixes, fixer.n_applied_fixes);
                    } else {
                        stdout.printf(
                            "Lint auto fix succeeded: %d fix(es) applied.\n",
                            fixer.n_applied_fixes);
                    }
                    if (fixer.n_applied_fixes > 0) {
                        stdout.puts(
                            "Some errors were fixed by auto fix. Run valalint again to get up-to-date results.\n");
                    }
                }
            }
            return 1;
        }
    }

    private int run() {
        context = new Vala.CodeContext();
        Vala.CodeContext.push(context);

        if (disable_diagnostic_colors == false) {
            unowned string env_colors = Environment.get_variable("VALA_COLORS");
            if (env_colors != null) {
                context.report.set_colors(env_colors);
            } else {
                context.report.set_colors(DEFAULT_COLORS);
            }
        }

        context.assert = !disable_assert;
        context.experimental = experimental;
        context.experimental_non_null = experimental_non_null;
        context.report.enable_warnings = !disable_warnings;
        context.report.set_verbose_errors(!quiet_mode);
        context.verbose_mode = verbose_mode;

        var config = new Config();
        bool explicit_config_file = config_file != null;
        if (config_file == null && !no_default_config_file) {
            config_file = ".valalint.conf";
        }
        if (config_file != null) {
            try {
                config.load_from_file(config_file, 0);
            } catch (GLib.Error e) {
                if (explicit_config_file || !(e is GLib.FileError.NOENT)) {
                    stderr.printf("Cannot load config file '%s'. %s.\n", config_file, e.message);
                    return 1;
                }
            }
        }
        foreach (unowned string check in checks) {
            string[] parts = check.split("=", 2);
            assert(parts.length < 3);
            string key = parts[0].strip().replace("-", "_");
            if (key != "") {
                string? value = parts.length == 2 ? parts[1].strip() : null;
                config.set_string(Config.CHECKS, key, value ?? "true");
            }
        }
        if (!config.has_group(Config.CHECKS)) {
            if (config_file != null) {
                stderr.printf(
                    "No checks are enabled. Use --check or add some checks to the config file (section '%s').\n",
                    Config.CHECKS);
            } else {
                stderr.printf("No checks are enabled. Use --config or --check to add some checks.\n");
            }
            return 1;
        }

        if (fix_errors) {
            config.set_string(Config.OPTIONS, "fix_errors", "true");
        }

        if (basedir == null) {
            context.basedir = Vala.CodeContext.realpath(".");
        } else {
            context.basedir = Vala.CodeContext.realpath(basedir);
        }
        if (directory != null) {
            context.directory = Vala.CodeContext.realpath(directory);
        } else {
            context.directory = context.basedir;
        }
        context.profile = Vala.Profile.GOBJECT;

        foreach (string source in sources) {
            context.add_source_filename(source, run_output, true);
        }

        if (context.report.get_errors() > 0 || (fatal_warnings && context.report.get_warnings() > 0)) {
            return quit();
        }

        var parser = new Vala.Parser ();
        parser.parse(context);
        if (context.report.get_errors() > 0 || (fatal_warnings && context.report.get_warnings() > 0)) {
            return quit();
        }

        Rule[] rules = {new IfElseRule(), new WhitespaceRule(), new NamespaceRule(), new VariableRule()};
        var linter = new Linter((owned) rules, config);
        linter.lint(context, new CodeVisitor(dump_tree));
        var fixer = new Fixer();
        foreach (unowned Rule rule in linter.rules) {
            fixer.add_fixes(rule.fixes);
        }
        fixer.fix();

        return quit(fixer);
    }


    static int main (string[] args) {
        Intl.setlocale(LocaleCategory.ALL, ""); // initialize locale
        try {
            var opt_context = new OptionContext ("- Vala Linter");
            opt_context.set_help_enabled(true);
            opt_context.add_main_entries(options, null);
            opt_context.parse(ref args);
        } catch (OptionError e) {
            stdout.printf("%s\n", e.message);
            stdout.printf("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 1;
        }

        if (version) {
            stdout.printf("Valalint %s\n", VERSION);
            return 0;
        }

        if (sources == null) {
            stderr.printf("No source file specified.\n");
            return 1;
        }

        return new Main().run();
    }
}
