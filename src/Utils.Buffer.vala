namespace Linter.Utils.Buffer {
    public char* move_to_eol(char* pos) {
        while (pos != null && *pos != '\n' && *pos != '\r') {
            pos++;
        }
        return pos;
    }

    public char* move_to_char(char* pos, char c) {
        while (pos != null && *pos != c) {
            pos++;
        }
        return pos;
    }

    public string? substring_to_eol(char* pos) {
        unowned string? str = (string?) pos;
        var len = move_to_eol(pos) - pos;
        return (len > 0) ? str.substring(0, (long) len) : null;
    }

    public string? substring_to_char(char* pos, char c) {
        unowned string? str = (string?) pos;
        var len = move_to_char(pos, c) - pos;
        return (len > 0) ? str.substring(0, (long) len) : null;
    }

    public string? substring(char* start, char* end) {
        if (start != null && end != null && end > start) {
            unowned string str = (string) start;
            return str.substring(0, (long) (end - start));
        }
        return null;
    }

    public bool has_trailing_whitespace(char* pos, out char* start, out char* end) {
        start = null;
        end = null;
        while (pos != null && *pos != '\0') {
            if (start == null && (*pos == ' ' || *pos == '\t')) {
                start = pos;
            } else if (start != null && *pos != ' ' && *pos != '\t') {
                start = null;
            }
            pos++;
        }
        if (start != null) {
            end = pos;
            return true;
        } else {
            return false;
        }
    }

    public int expanded_size(char* start, char* end) {
        if (start == null || end == null || start > end) {
            return 0;
        }
        var size = 0;
        while (start != null && start != end) {
            switch (*start) {
            case '\0':
                return size;
            case '\t':
                size += 4;
                break;
            default:
                size++;
                break;
            }
            start++;
        }
        return size;
    }



} // namespace Linter.Utils.Buffer
