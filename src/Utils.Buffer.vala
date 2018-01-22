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

public char* skip_whitespace_stop_at_eol(char* pos) {
    for (char* i = pos; i != null; i++) {
        switch (*i) {
        case ' ':
        case '\t':
            break;
        default:
            return i;
        }
    }
    return pos;
}

public char* skip_whitespace_backwards(char* pos, int limit=-1) {
    if (pos == null || limit == 0) {
        return pos;
    }
    while (limit-- != 0 && pos - 1 != null) {
        pos--;
        switch (*pos) {
        case ' ':
        case '\t':
            break;
        default:
            return pos + 1;
        }
    }
    return pos;
}

public string? substring_to_eol(char* pos) {
    unowned string? str = (string?) pos;
    size_t len = move_to_eol(pos) - pos;
    return (len > 0) ? str.substring(0, (long) len) : null;
}

public string? substring_to_char(char* pos, char c) {
    unowned string? str = (string?) pos;
    size_t len = move_to_char(pos, c) - pos;
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
    int size = 0;
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

public char* index_of_char(char* pos, char c) {
    while (pos != null && *pos != '\0') {
        if (*pos == c) {
            return pos;
        }
        pos++;
    }
    return null;
}

} // namespace Linter.Utils.Buffer
