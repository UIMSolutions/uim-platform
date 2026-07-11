/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.views.table_view;

import std.array   : appender, replicate;
import std.string  : leftJustify, rightJustify;
import std.conv    : to;
import std.stdio   : writeln, write;
import std.algorithm : max, map;
import std.range   : zip;

@safe:
/// Generic ASCII table renderer for CLI output.
struct TableView {
    private string[] _headers;
    private string[][] _rows;
    private int[] _widths;

    this(string[] headers) {
        _headers = headers;
        _widths.length = headers.length;
        foreach (i, h; headers)
            _widths[i] = cast(int) h.length;
    }

    void addRow(string[] cols ...) {
        string[] row;
        foreach (i, c; cols) {
            row ~= c;
            if (i < _widths.length && cast(int) c.length > _widths[i])
                _widths[i] = cast(int) c.length;
        }
        _rows ~= row;
    }

    void render() const {
        auto sep = buildSeparator();
        writeln(sep);
        write("| ");
        foreach (i, h; _headers) {
            write(h.leftJustify(_widths[i]));
            write(i + 1 < _headers.length ? " | " : " |");
        }
        writeln();
        writeln(sep);
        foreach (row; _rows) {
            write("| ");
            foreach (i; 0 .. _headers.length) {
                immutable cell = i < row.length ? row[i] : "";
                write(cell.leftJustify(_widths[i]));
                write(i + 1 < _headers.length ? " | " : " |");
            }
            writeln();
        }
        writeln(sep);
        writeln(_rows.length.to!string ~ " row(s)");
    }

    private string buildSeparator() const {
        auto buf = appender!string;
        buf ~= "+";
        foreach (w; _widths) {
            buf ~= replicate("-", w + 2);
            buf ~= "+";
        }
        return buf[];
    }
}
