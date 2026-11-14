/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Parsing of the string valued domain enumerations (case insensitive).
module uim.platform.oauth.domain.enumerations.parse;

import std.traits : EnumMembers;
import std.uni : icmp;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// All values of a string enum, in declaration order.
string[] domainEnumValues(E)() if (is(E : string) && is(E == enum)) {
  string[] values;
  static foreach (m; EnumMembers!E)
    values ~= cast(string) m;
  return values;
}

/// Parse a string enum value; throws OAuthException.invalid.
E parseDomainEnum(E)(string text, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  auto t = text.strip;
  static foreach (m; EnumMembers!E)
    if (icmp(cast(string) m, t) == 0)
      return m;
  throw OAuthException.invalid("Invalid " ~ field ~ " '" ~ text ~ "' (allowed: " ~ domainEnumValues!E.join(", ") ~ ")");
}

/// Parse or fall back to a default (empty text → default).
E parseDomainEnumOr(E)(string text, E fallback, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  return text.strip.length == 0 ? fallback : parseDomainEnum!E(text, field);
}

/// Parse a list of enum values (duplicates removed).
E[] parseDomainEnums(E)(const string[] texts, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  E[] values;
  foreach (t; texts) {
    auto v = parseDomainEnum!E(t, field);
    if (!values.canFind(v))
      values ~= v;
  }
  return values;
}

/// Enum values → their strings.
string[] enumTexts(E)(const E[] values) if (is(E : string) && is(E == enum)) {
  string[] texts;
  foreach (v; values)
    texts ~= cast(string) v;
  return texts;
}

///
unittest {
  assert(parseDomainEnum!GrantType("CLIENT_CREDENTIALS") == GrantType.clientCredentials);
  assert(parseDomainEnumOr!ClientType("", ClientType.confidential) == ClientType.confidential);
  assert(parseDomainEnums!GrantType(["refresh_token", "refresh_token"]) == [GrantType.refreshToken]);
  assert(enumTexts([GrantType.authorizationCode]) == ["authorization_code"]);
  assert(failsWith(OAuthErrorKind.invalid, () { parseDomainEnum!GrantType("implicit"); }));
}
