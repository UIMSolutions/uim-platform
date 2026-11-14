/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Scope values (RFC 6749 §3.3): space delimited, case sensitive strings
/// made of printable ASCII except space, double quote and backslash.
module uim.platform.oauth.domain.types.scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// True for a syntactically valid scope token (e.g. "orders.read", "uaa.resource").
bool isValidScopeName(string name) pure {
  if (name.length == 0 || name.length > 128)
    return false;
  foreach (char c; name)
    if (c <= 0x20 || c >= 0x7F || c == '"' || c == '\\')
      return false;
  return true;
}

/// Split a scope parameter (space or comma separated), drop blanks and duplicates, keep the order.
string[] parseScopeList(string text) pure {
  string[] result;
  foreach (part; text.replace(",", " ").split(" "))
    if (part.length > 0 && !result.canFind(part))
      result ~= part;
  return result;
}

/// Normalise a list (trim, drop blanks and duplicates).
string[] normalizeScopes(const string[] scopes) pure {
  string[] result;
  foreach (s; scopes) {
    auto t = s.strip;
    if (t.length > 0 && !result.canFind(t))
      result ~= t;
  }
  return result;
}

/// The RFC 6749 "scope" parameter form.
string joinScopes(const string[] scopes) pure {
  return scopes.join(" ");
}

/// True if every scope of subset is in superset.
bool isScopeSubset(const string[] subset, const string[] superset) pure {
  return subset.all!(s => superset.canFind(s));
}

///
unittest {
  assert(isValidScopeName("orders.read") && isValidScopeName("uaa.resource"));
  assert(!isValidScopeName("") && !isValidScopeName("a b") && !isValidScopeName("a\"b"));
  assert(parseScopeList(" a  b,a c ") == ["a", "b", "c"]);
  assert(normalizeScopes([" x", "x", "", "y"]) == ["x", "y"]);
  assert(joinScopes(["a", "b"]) == "a b");
  assert(isScopeSubset(["a"], ["a", "b"]) && !isScopeSubset(["c"], ["a"]) && isScopeSubset([], ["a"]));
}
