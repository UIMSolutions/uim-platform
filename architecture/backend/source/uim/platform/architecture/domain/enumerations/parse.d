/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Parsing of string enumerations (case-insensitive, '-' and '_' ignored,
/// so "in-development", "IN_DEVELOPMENT" and "inDevelopment" are equal).
module uim.platform.architecture.domain.enumerations.parse;

import std.traits : EnumMembers;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// Comparison form: lowercase without '-', '_' and spaces.
string enumKey(string text) pure {
  string result;
  foreach (c; text.strip)
    if (c != '-' && c != '_' && c != ' ')
      result ~= c >= 'A' && c <= 'Z' ? cast(char)(c + 32) : c;
  return result;
}

/// All values of a string enum.
string[] enumValues(E)() pure {
  string[] values;
  static foreach (m; EnumMembers!E)
    values ~= cast(string) m;
  return values;
}

/// Parse a string enum; throws invalid naming the allowed values.
E parseEnumValue(E)(string text, string what) {
  auto key = enumKey(text);
  static foreach (m; EnumMembers!E)
    if (enumKey(cast(string) m) == key)
      return m;
  throw ArchitectureException.invalid(format("%s '%s' is invalid (allowed: %s)", what, text, enumValues!E.join(", ")));
}

/// Parse a value from a list of names (canonical spelling is returned).
string parseNamedValue(string text, const string[] names, string what) {
  auto key = enumKey(text);
  foreach (n; names)
    if (enumKey(n) == key)
      return n;
  throw ArchitectureException.invalid(format("%s '%s' is invalid (allowed: %s)", what, text, names.join(", ")));
}

///
unittest {
  enum Color : string {
    darkRed = "darkRed",
    blue = "blue"
  }

  assert(parseEnumValue!Color("DARK_RED", "Color") == Color.darkRed);
  assert(parseEnumValue!Color("dark-red", "Color") == Color.darkRed);
  assert(failsWith(ArchitectureErrorKind.invalid, () { parseEnumValue!Color("green", "Color"); }));
  assert(parseNamedValue("application component", ["ApplicationComponent"], "x") == "ApplicationComponent");
}
