/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming rules of ABAP Cloud objects, system IDs, users and e-mail addresses.
module uim.platform.abap_environment.domain.services.names;

import std.ascii : isUpper, isDigit, isAlphaNum;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// SIDs that SAP reserves (SAP Note 1979280); they cannot be used for a system.
enum string[] reservedSystemIds = [
  "ADD", "ADM", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIN", "BIT", "CDC", "COM",
  "CON", "DAA", "DBA", "DBM", "DBO", "DTD", "ECO", "END", "EPS", "EXE", "FOR", "GET", "GID", "IBM",
  "INT", "KEY", "LIB", "LOG", "LPT", "MAP", "MAX", "MEM", "MIG", "MIN", "MON", "NET", "NIX", "NOT",
  "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG",
  "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "TRC", "UID", "USE", "USR", "VAR",
];

/// A SAP system ID: three characters, uppercase letter first, then uppercase
/// letters or digits, not reserved.
void validateSystemId(string sid) {
  validate(sid.length == 3, "SAP System ID must be exactly 3 characters");
  validate(isUpper(sid[0]), "SAP System ID must start with an uppercase letter");
  foreach (c; sid[1 .. $])
    validate(isUpper(c) || isDigit(c), "SAP System ID may only contain uppercase letters and digits");
  validate(!reservedSystemIds.canFind(sid), "SAP System ID '" ~ sid ~ "' is reserved by SAP");
}

/// A display name (system, arrangement, job): 1–80 printable characters.
void validateDisplayName(string kind, string name) {
  validate(name.strip.length > 0, kind ~ " name is required");
  validate(name.length <= 80, kind ~ " name must not exceed 80 characters");
  validate(name == name.strip, kind ~ " name must not start or end with blanks");
}

/// An ABAP repository object name: uppercase letters, digits and "_",
/// optionally in a namespace ("/DMO/FLIGHT"), at most `maxLength` characters.
void validateAbapName(string kind, string name, size_t maxLength = 30) {
  validate(name.length > 0, kind ~ " name is required");
  validate(name.length <= maxLength, kind ~ " name must not exceed " ~ maxLength.to!string ~ " characters");
  auto rest = name;
  if (rest[0] == '/') {
    auto close = rest[1 .. $].indexOf('/');
    validate(close > 0, kind ~ " name '" ~ name ~ "' has an incomplete namespace");
    foreach (c; rest[1 .. close + 1])
      validate(isUpper(c) || isDigit(c), kind ~ " namespace may only contain uppercase letters and digits");
    rest = rest[close + 2 .. $];
  }
  validate(rest.length > 0, kind ~ " name '" ~ name ~ "' is empty after the namespace");
  validate(isUpper(rest[0]), kind ~ " name must start with an uppercase letter (got '" ~ name ~ "')");
  foreach (c; rest)
    validate(isUpper(c) || isDigit(c) || c == '_', kind ~ " name may only contain A–Z, 0–9 and '_' (got '" ~ name ~ "')");
}

/// A business user name: 1–40 characters, letters, digits and . _ - @
void validateUserName(string name) {
  validate(name.length > 0, "User name is required");
  validate(name.length <= 40, "User name must not exceed 40 characters");
  foreach (c; name)
    validate(isAlphaNum(c) || c == '.' || c == '_' || c == '-' || c == '@',
      "User name may only contain letters, digits and . _ - @");
}

/// A plausible e-mail address (local@domain.tld).
bool isValidEmail(string email) pure {
  auto at = email.indexOf('@');
  if (at <= 0 || at != email.lastIndexOf('@') || email.canFind(' '))
    return false;
  auto domain = email[at + 1 .. $];
  auto dot = domain.lastIndexOf('.');
  return dot > 0 && dot < cast(long) domain.length - 2;
}

void validateEmail(string what, string email) {
  validate(email.length > 0, what ~ " is required");
  validate(isValidEmail(email), what ~ " '" ~ email ~ "' is not a valid e-mail address");
}

/// An http(s) URL.
bool isHttpUrl(string url) pure {
  return (url.startsWith("https://") && url.length > 8) || (url.startsWith("http://") && url.length > 7);
}

///
unittest {
  validateSystemId("H01");
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (AbapValidationException)
      return true;
    return false;
  }

  assert(failed(() => validateSystemId("SAP")));
  assert(failed(() => validateSystemId("h01")));
  assert(failed(() => validateSystemId("1AB")));
  assert(failed(() => validateSystemId("ABCD")));

  validateAbapName("Binding", "ZUI_TRAVEL_O4");
  validateAbapName("Component", "/DMO/FLIGHT");
  assert(failed(() => validateAbapName("Binding", "zui_travel")));
  assert(failed(() => validateAbapName("Binding", "/DMO/")));
  assert(failed(() => validateAbapName("Binding", "Z" ~ "A".replicate(30))));

  assert(isValidEmail("jane.doe@example.com"));
  assert(!isValidEmail("jane@") && !isValidEmail("@x.com") && !isValidEmail("a@b@c.de") && !isValidEmail("a@b.c"));
  assert(isHttpUrl("https://github.com/x/y.git") && !isHttpUrl("ftp://x"));
  validateUserName("jane.doe@corp");
  assert(failed(() => validateUserName("jane doe")));
}
