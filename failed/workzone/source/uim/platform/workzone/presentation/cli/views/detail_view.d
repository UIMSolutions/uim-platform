/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.views.detail_view;

import std.stdio  : writeln, write;
import std.string : leftJustify;
import std.conv   : to;

@safe:
/// Key-value detail block for displaying a single entity's properties.
struct DetailView {
    private string _heading;
    private string[2][] _fields; // [label, value] pairs

    this(string heading) { _heading = heading; }

    void add(string label, string value) { _fields ~= [label, value]; }

    void render() const {
        writeln();
        writeln("  ── " ~ _heading ~ " ──");
        if (_fields.length == 0) {
            writeln("  (no data)");
        } else {
            // Find longest label for alignment
            size_t labelWidth = 0;
            foreach (f; _fields)
                if (f[0].length > labelWidth) labelWidth = f[0].length;

            foreach (f; _fields) {
                write("  ");
                write(f[0].leftJustify(labelWidth + 2));
                writeln(f[1]);
            }
        }
        writeln();
    }

    void renderSuccess(string message) const {
        writeln("  [OK] " ~ message);
    }

    void renderError(string message) const {
        writeln("  [ERROR] " ~ message);
    }
}
