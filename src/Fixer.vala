public class Linter.Fixer {
    public Vala.Map<string, Vala.List<Fix>> all_fixes = new Vala.HashMap<string, Vala.List<Fix>>(str_hash, str_equal);
    public int n_applied_fixes {get; private set; default = 0;}
    public int n_failed_fixes {get; private set; default = 0;}

    public Fixer() {
    }

    public void add_fixes(Vala.List<Fix> fixes) {
        foreach (Fix fix in fixes) {
            unowned string filename = fix.file.filename;
            Vala.List<Fix>? list = all_fixes[filename];
            if (list == null) {
                list = new Vala.ArrayList<Fix>();
                all_fixes[filename] = list;
            }
            list.add(fix);
        }
    }

    public void fix() {
        Vala.MapIterator<string, Vala.List<Fix>> cursor = all_fixes.map_iterator();
        while (cursor.next()) {
            apply_fixes(cursor.get_value());
        }
    }

    private void apply_fixes(Vala.List<Fix> fixes) {
        if (fixes.is_empty) {
            return;
        }
        fixes.sort(Fix.compare_func);
        Vala.Iterator<Fix> fix_iter = fixes.iterator();
        assert(fix_iter.next());
        Fix? fix = fix_iter.get();

        Vala.SourceFile file = fix.file;
        char* content = file.get_mapped_contents();
        assert(content != null);

        var buffer = new StringBuilder("");
        char* processed = content;
        for (char* pos = content; pos != null && *pos != 0; pos++) {
            while (fix != null && pos - content == fix.begin) {
                n_applied_fixes++;
                if (pos - processed > 0) {
                    buffer.append_len((string) processed, (ssize_t) (pos - processed));
                }
                if (fix.replacement != null) {
                    buffer.append(fix.replacement);
                }
                processed = content + fix.end;

                fix = null;
                while (fix_iter.next()) {
                    fix = fix_iter.get();
                    if (file != fix.file || fix.begin < processed - content) {
                        fix = null;
                        n_failed_fixes++;
                    } else {
                        break;
                    }
                }
            }
        }
        if (processed != null && *processed != 0) {
            buffer.append((string) processed);
        }
        if (FileUtils.rename(file.filename, file.filename + "~") == 0) {
            FileStream stream = FileStream.open(file.filename, "w");
            stream.puts(buffer.str);
        } else {
            warning("Failed to rename '%s'", file.filename);
        }
    }
}
