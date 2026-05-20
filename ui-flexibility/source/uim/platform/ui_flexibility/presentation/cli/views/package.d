/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.cli.views;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Renders items as a text table to stdout.
struct TableView {
  static void render(T)(T[] items, string function(T) @safe formatter) {
    import std.stdio : writeln;
    writeln("ID | Details");
    writeln("--------------------------------------------------");
    foreach (i; items) writeln(formatter(i));
  }
}

/// Renders items as JSON array to stdout.
struct JsonView {
  static void render(T)(T[] items, Json function(T) @safe toJson) {
    import std.stdio : writeln;
    auto arr = Json.emptyArray;
    foreach (i; items) arr ~= toJson(i);
    writeln(arr.toPrettyString());
  }
}

/// Renders items as CSV to stdout.
struct CsvView {
  static void render(string[] headers, string[][] rows) {
    import std.stdio : writeln;
    import std.string : join;
    writeln(headers.join(","));
    foreach (r; rows) writeln(r.join(","));
  }
}
