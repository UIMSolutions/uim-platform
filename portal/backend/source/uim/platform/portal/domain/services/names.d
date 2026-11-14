/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Aliases (URL slugs), language codes and URLs.
module uim.platform.portal.domain.services.names;

import std.ascii : isAlphaNum, isDigit, isLower, isAlpha;
import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// URL slug: lowercase letters, digits and "-", starts and ends alphanumeric, ≤ 63 chars.
bool isSlug(string s) pure nothrow {
  if (s.length == 0 || s.length > 63)
    return false;
  foreach (i, c; s) {
    bool alnum = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9');
    if (!alnum && !(c == '-' && i > 0 && i + 1 < s.length))
      return false;
  }
  return true;
}

/// "Sales Launchpad (EMEA)" → "sales-launchpad-emea". Never empty.
string slugify(string text, string fallback = "item") pure {
  string result;
  bool dash;
  foreach (dchar c; text) {
    if (c >= 'A' && c <= 'Z')
      c = cast(dchar)(c + 32);
    if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
      if (dash && result.length > 0)
        result ~= '-';
      result ~= cast(char) c;
      dash = false;
    } else
      dash = true;
    if (result.length >= 63)
      break;
  }
  while (result.length > 0 && result[$ - 1] == '-')
    result = result[0 .. $ - 1];
  return result.length == 0 ? fallback : result;
}

/// Validate the alias of a `kind`.
void validateAlias(string kind, string alias_) {
  validate(alias_.length > 0, kind ~ " alias is required");
  validate(isSlug(alias_), kind ~ " alias '" ~ alias_
      ~ "' must be a URL slug (lowercase letters, digits and '-', max. 63 characters)");
}

/// ISO 639-1/-2 language code, optionally with a region or script: "de", "pt-BR", "zh_Hant".
bool isLanguageCode(string s) pure nothrow {
  size_t i;
  while (i < s.length && s[i] >= 'a' && s[i] <= 'z')
    i++;
  if (i < 2 || i > 3)
    return false;
  if (i == s.length)
    return true;
  if (s[i] != '-' && s[i] != '_')
    return false;
  auto rest = s[i + 1 .. $];
  if (rest.length < 2 || rest.length > 4)
    return false;
  foreach (c; rest)
    if (!isAlpha(c) && !isDigit(c))
      return false;
  return true;
}

void validateLanguage(string what, string code) {
  validate(isLanguageCode(code), what ~ " '" ~ code ~ "' is not a language code (e.g. en, de, pt-BR)");
}

/// An absolute http(s) URL, a relative path ("/apps/x", "./x") or a launchpad
/// intent ("#Order-display"). Scripting schemes are rejected.
bool isNavigableUrl(string s) pure {
  import std.string : startsWith, toLower, strip;

  auto v = s.strip.toLower;
  if (v.length == 0 || v.startsWith("javascript:") || v.startsWith("data:") || v.startsWith("vbscript:"))
    return false;
  return v.startsWith("https://") || v.startsWith("http://") || v.startsWith("/") || v.startsWith("./")
    || v.startsWith("../") || v.startsWith("#");
}

/// An absolute https URL.
bool isHttpsUrl(string s) pure {
  import std.string : startsWith;

  return s.startsWith("https://") && s.length > "https://".length;
}

/// An SAP icon ("sap-icon://home") or an image URL.
bool isIconRef(string s) pure {
  import std.string : startsWith;

  return s.length == 0 || (s.startsWith("sap-icon://") && s.length > 11) || isNavigableUrl(s);
}

///
unittest {
  assert(isSlug("sales-emea") && !isSlug("Sales") && !isSlug("-a") && !isSlug(""));
  assert(slugify("Sales Launchpad (EMEA)") == "sales-launchpad-emea");
  assert(slugify("  ") == "item" && slugify("Ärger", "x") == "rger");
  assert(isLanguageCode("de") && isLanguageCode("pt-BR") && isLanguageCode("zh_Hant"));
  assert(!isLanguageCode("German") && !isLanguageCode("d") && !isLanguageCode("de-"));
  assert(isNavigableUrl("https://x.example.com") && isNavigableUrl("#SalesOrder-display") && isNavigableUrl("/apps/x"));
  assert(!isNavigableUrl("javascript:alert(1)") && !isNavigableUrl("ftp://x"));
  assert(isIconRef("sap-icon://home") && isIconRef("") && !isIconRef("sap-icon://"));
}
