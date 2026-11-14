/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value helpers for the attributes of an authorization request.
module uim.platform.authorization.domain.types.attributes;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Parse "country=US, department=Sales" (also ';' separated) into a map.
string[string] parseAttributes(string text) {
  string[string] result;
  foreach (part; text.split!(c => c == ',' || c == ';')) {
    auto p = part.strip;
    if (p.length == 0)
      continue;
    auto eq = p.indexOf('=');
    if (eq <= 0)
      throw AuthorizationException.invalid("Invalid attribute '" ~ p ~ "' (expected key=value)");
    result[p[0 .. eq].strip] = p[eq + 1 .. $].strip;
  }
  return result;
}

/// Render attributes as "k=v, k2=v2" (sorted by key, stable for logs and tests).
string attributesText(const string[string] attributes) {
  return attributes.keys.sort.map!(k => k ~ "=" ~ attributes[k]).join(", ");
}

/// Split a comma separated list ("Admins, Support") into trimmed, non empty items.
string[] splitList(string text) {
  return text.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
}

///
unittest {
  mixin(ShowTest!("attributes"));

  auto a = parseAttributes("country=US, department = Sales;level=3");
  assert(a == ["country": "US", "department": "Sales", "level": "3"]);
  assert(attributesText(a) == "country=US, department=Sales, level=3");
  assert(parseAttributes("").length == 0);
  assert(splitList(" a, ,b ") == ["a", "b"]);
  assert(failsWith(AuthorizationErrorKind.invalid, () { parseAttributes("country"); }));
}
