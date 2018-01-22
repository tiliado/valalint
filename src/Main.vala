class Linter.Main {
    private const string DEFAULT_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";

    static string basedir;
    static string directory;
    static string config_file;
    static bool version;
    static bool api_version;
    static bool dump_tree;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] sources;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] vapi_directories;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] gir_directories;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] metadata_directories;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] packages;
    static string target_glib;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] checks;
    static bool disable_assert;
    static bool experimental;
    static bool experimental_non_null;
    static bool gobject_tracing;
    static bool disable_warnings;
    static string pkg_config_command;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] defines;
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
            "vapidir", 0, 0, OptionArg.FILENAME_ARRAY, ref vapi_directories,
            "Look for package bindings in DIRECTORY", "DIRECTORY..."
        }, {
            "girdir", 0, 0, OptionArg.FILENAME_ARRAY, ref gir_directories,
            "Look for .gir files in DIRECTORY", "DIRECTORY..."
        }, {
            "metadatadir", 0, 0, OptionArg.FILENAME_ARRAY, ref metadata_directories,
            "Look for GIR .metadata files in DIRECTORY", "DIRECTORY..."
        }, {
            "pkg", 0, 0, OptionArg.STRING_ARRAY, ref packages,
            "Include binding for PACKAGE", "PACKAGE..."
        }, {
            "basedir", 'b', 0, OptionArg.FILENAME, ref basedir,
            "Base source directory", "DIRECTORY"
        }, {
            "version", 0, 0, OptionArg.NONE, ref version,
            "Display version number", null
        }, {
            "api-version", 0, 0, OptionArg.NONE, ref api_version,
            "Display API version number", null
        }, {
            "dump-tree", 0, 0, OptionArg.NONE, ref dump_tree,
            "Dump code visitor tree.", null
        }, {
            "define", 'D', 0, OptionArg.STRING_ARRAY, ref defines,
            "Define SYMBOL", "SYMBOL..."
        }, {
            "enable-experimental", 0, 0, OptionArg.NONE, ref experimental,
            "Enable experimental features", null
        }, {
            "enable-experimental-non-null", 0, 0, OptionArg.NONE, ref experimental_non_null,
            "Enable experimental enhancements for non-null types", null
        }, {
            "enable-gobject-tracing", 0, 0, OptionArg.NONE, ref gobject_tracing,
            "Enable GObject creation tracing", null
        }, {
            "pkg-config", 0, 0, OptionArg.STRING, ref pkg_config_command,
            "Use COMMAND as pkg-config command", "COMMAND"
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
            "target-glib", 0, 0, OptionArg.STRING, ref target_glib,
            "Target version of glib for code generation", "MAJOR.MINOR"
        }, {
            "", 0, 0, OptionArg.FILENAME_ARRAY, ref sources, null, "FILE..."
        }, {
            null
        }
    };

    private int quit() {
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
        context.gobject_tracing = gobject_tracing;
        context.report.enable_warnings = !disable_warnings;
        context.report.set_verbose_errors(!quiet_mode);
        context.verbose_mode = verbose_mode;

        var config = new Config();
        try {
            config.load_from_file(config_file ?? ".valalint.conf", 0);
        } catch (GLib.Error e) {
            if (config_file != null || !(e is GLib.FileError.NOENT)) {
                stderr.printf("Cannot load config file '%s'. %s.\n", config_file, e.message);
                return 1;
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
        context.vapi_directories = vapi_directories;
        context.gir_directories = gir_directories;
        context.metadata_directories = metadata_directories;
        context.profile = Vala.Profile.GOBJECT;
        context.add_define("GOBJECT");

        if (defines != null) {
            foreach (string define in defines) {
                context.add_define(define);
            }
        }

        for (int i = 2; i <= 36; i += 2) {
            context.add_define("VALA_0_%d".printf(i));
        }

        int glib_major = 2;
        int glib_minor = 32;
        if (target_glib != null && target_glib.scanf("%d.%d", out glib_major, out glib_minor) != 2) {
            Vala.Report.error(null, "Invalid format for --target-glib");
        }

        context.target_glib_major = glib_major;
        context.target_glib_minor = glib_minor;
        if (context.target_glib_major != 2) {
            Vala.Report.error(null, "This version of valac only supports GLib 2");
        }

        for (int i = 16; i <= glib_minor; i += 2) {
            context.add_define("GLIB_2_%d".printf(i));
        }

        /* default packages */
        context.add_external_package("glib-2.0");
        context.add_external_package("gobject-2.0");

        if (packages != null) {
            foreach (string package in packages) {
                context.add_external_package(package);
            }
            packages = null;
        }

        if (context.report.get_errors() > 0 || (fatal_warnings && context.report.get_warnings() > 0)) {
            return quit();
        }

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

        Rule[] rules = {new WhitespaceRule(), new NamespaceRule(), new VariableRule()};
        var linter = new Linter((owned) rules, config);
        linter.lint(context, new CodeVisitor(dump_tree));
        return quit();
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
            stdout.printf("Vala %s\n", "VERSION");
            return 0;
        } else if (api_version) {
            stdout.printf("%s\n", "API_VERSION");
            return 0;
        }

        if (sources == null) {
            stderr.printf("No source file specified.\n");
            return 1;
        }

        return new Main().run();
    }
}
