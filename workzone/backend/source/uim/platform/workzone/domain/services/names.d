/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming, URL, colour and permission rules.
module uim.platform.workzone.domain.services.names;

import std.ascii : isAlphaNum, isHexDigit, isLower, isDigit;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A display name: 1..max printable characters, no control characters.
void validateDisplayName(string label, string value, size_t max = 120) {
  auto v = value.strip;
  validate(v.length > 0, label ~ " is required");
  validate(v.length <= max, label ~ " must not exceed " ~ max.to!string ~ " characters");
  validate(!v.any!(c => c < 0x20), label ~ " must not contain control characters");
}

/// "Sales & Marketing EMEA" → "sales-marketing-emea".
string toSlug(string value) {
  string result;
  bool dash;
  foreach (c; value.strip.toLower) {
    if (isAlphaNum(c)) {
      result ~= c;
      dash = false;
    } else if (!dash && result.length > 0) {
      result ~= '-';
      dash = true;
    }
  }
  while (result.length > 0 && result[$ - 1] == '-')
    result = result[0 .. $ - 1];
  return result.length > 64 ? result[0 .. 64] : result;
}

/// URL alias: lowercase letters, digits and single dashes, 2..64 characters.
bool isSlug(string value) pure {
  if (value.length < 2 || value.length > 64 || value[0] == '-' || value[$ - 1] == '-')
    return false;
  foreach (i, c; value) {
    if (c == '-') {
      if (value[i - 1] == '-')
        return false;
    } else if (!(isLower(c) || isDigit(c)))
      return false;
  }
  return true;
}

void validateSlug(string label, string value) {
  validate(isSlug(value), label ~ " '" ~ value ~ "' must be 2-64 lowercase letters, digits or dashes (e.g. sales-emea)");
}

/// An absolute http(s) URL.
bool isHttpUrl(string value) pure {
  auto v = value.strip;
  foreach (scheme; ["https://", "http://"])
    if (v.startsWith(scheme) && v.length > scheme.length && !v.canFind(" "))
      return true;
  return false;
}

/// An absolute http(s) URL or an application relative path ("/sites/x", "#Shell-home").
bool isLaunchTarget(string value) pure {
  auto v = value.strip;
  return isHttpUrl(v) || ((v.startsWith("/") || v.startsWith("#")) && v.length > 1 && !v.canFind(" "));
}

/// Optional URL field: empty or http(s).
void validateOptionalUrl(string label, string value) {
  validate(value.strip.length == 0 || isHttpUrl(value), label ~ " '" ~ value ~ "' must be an http(s) URL");
}

/// "#RGB" or "#RRGGBB".
bool isHexColor(string value) pure {
  if (!(value.length == 4 || value.length == 7) || value[0] != '#')
    return false;
  return value[1 .. $].all!(c => isHexDigit(c));
}

/// Optional colour field: empty or a hex colour.
void validateOptionalColor(string label, string value) {
  validate(value.length == 0 || isHexColor(value), label ~ " '" ~ value ~ "' must be a hex colour like #0A6ED1");
}

/// Very small e-mail check: local@domain.tld without blanks.
bool isEmail(string value) pure {
  auto at = value.indexOf('@');
  if (at <= 0 || value.canFind(" ") || value.count('@') != 1)
    return false;
  auto domain = value[at + 1 .. $];
  auto dot = domain.lastIndexOf('.');
  return dot > 0 && dot < cast(ptrdiff_t) domain.length - 1;
}

/// "verb:object" with lowercase words; "*" is a wildcard ("read:workspace", "*:*").
bool isPermission(string value) pure {
  auto parts = value.split(":");
  if (parts.length != 2)
    return false;
  foreach (p; parts)
    if (!(p == "*" || (p.length > 0 && p.all!(c => isLower(c) || c == '-'))))
      return false;
  return true;
}

/// Trimmed, non-empty, de-duplicated names in input order.
string[] normalizedNames(const string[] names) {
  string[] result;
  foreach (n; names) {
    auto v = n.strip;
    if (v.length > 0 && !result.canFind(v))
      result ~= v;
  }
  return result;
}

/// Names of `wanted` missing in `available`.
string[] missingNames(const string[] wanted, const string[] available) {
  string[] result;
  foreach (w; wanted)
    if (!available.canFind(w))
      result ~= w;
  return result;
}

///
unittest {
  assert(toSlug("Sales & Marketing  EMEA!") == "sales-marketing-emea");
  assert(isSlug("sales-emea") && !isSlug("Sales") && !isSlug("a--b") && !isSlug("-a"));
  assert(isHttpUrl("https://x.example.com") && !isHttpUrl("ftp://x") && !isHttpUrl("https://"));
  assert(isLaunchTarget("/sites/home") && isLaunchTarget("#Shell-home") && !isLaunchTarget("home"));
  assert(isHexColor("#0A6ED1") && isHexColor("#fff") && !isHexColor("0A6ED1") && !isHexColor("#12"));
  assert(isEmail("jane@example.com") && !isEmail("jane@") && !isEmail("jane.example.com"));
  assert(isPermission("read:workspace") && isPermission("*:*") && !isPermission("Read:x") && !isPermission("read"));
  assert(normalizedNames([" a", "b", "a", ""]) == ["a", "b"]);
  assert(missingNames(["a", "b"], ["b"]) == ["a"]);
}
