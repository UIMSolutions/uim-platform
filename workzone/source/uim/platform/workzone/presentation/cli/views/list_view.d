/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.views.list_view;

import std.stdio  : writeln, write;
import std.string : leftJustify;
import std.conv   : to;

@safe:
/// Simple numbered list renderer.
struct ListView {
    private string _title;
    private string[] _items;

    this(string title) { _title = title; }

    void add(string item) { _items ~= item; }
    void clear()          { _items = null; }

    void render() const {
        writeln();
        writeln("  " ~ _title);
        writeln("  " ~ replicate("─", _title.length));
        if (_items.length == 0) {
            writeln("  (empty)");
        } else {
            foreach (i, item; _items) {
                immutable idx = (i + 1).to!string;
                writeln("  " ~ idx.leftJustify(3) ~ " " ~ item);
            }
        }
        writeln();
    }

    private static string replicate(string ch, size_t n) @safe pure {
        import std.array : replicate;
        return ch.replicate(n);
    }
}
