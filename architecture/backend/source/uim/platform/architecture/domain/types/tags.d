/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Free text lists (tags, interfaces): trimmed, de-duplicated, bounded.
module uim.platform.architecture.domain.types.tags;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum size_t maxListEntries = 50;
enum size_t maxListEntryLength = 128;

/// Trim entries, drop empty ones and duplicates (first occurrence wins).
/// lowercase = true normalizes tags ("Integration" == "integration").
string[] normalizeList(const string[] values, bool lowercase = false) {
  string[] result;
  foreach (v; values) {
    auto s = v.strip.idup;
    if (lowercase)
      s = s.toLower;
    if (s.length > 0 && !result.canFind(s))
      result ~= s;
  }
  return result;
}

void requireList(const string[] values, string what) {
  if (values.length > maxListEntries)
    throw ArchitectureException.invalid(format("%s: at most %d entries", what, maxListEntries));
  foreach (v; values)
    requireMaxLength(v, maxListEntryLength, what ~ " entry");
}

///
unittest {
  assert(normalizeList([" Event ", "event", "", "API"], true) == ["event", "api"]);
  assert(normalizeList(["OData v4", "OData v4"]) == ["OData v4"]);
  assert(failsWith(ArchitectureErrorKind.invalid, () { requireList(new string[51], "Tags"); }));
}
