/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic, case-insensitive enum <-> text conversion used by every layer.
///
/// Member names ending in "_" (D keywords such as `auto_`) are written without
/// the underscore; string based enums (`enum ModuleType : string`) are written
/// with their value ("api-gateway").
module uim.platform.kyma.helpers.enums;

import std.traits : EnumMembers, OriginalType, Unqual;
import std.conv : to;
import std.string : toLower, strip, replace;

@safe:

private string normalize(string s) pure {
  return s.strip.toLower.replace("-", "").replace("_", "").replace(" ", "");
}

/// The external text of an enum member.
string enumText(E)(E value) if (is(E == enum)) {
  static if (is(Unqual!(OriginalType!E) == string))
    return cast(string) value;
  else {
    auto name = value.to!string;
    return name.length > 1 && name[$ - 1] == '_' ? name[0 .. $ - 1] : name;
  }
}

/// All external texts of an enum, in declaration order.
string[] enumTexts(E)() if (is(E == enum)) {
  string[] result;
  foreach (m; [EnumMembers!E])
    result ~= enumText(m);
  return result;
}

/// Parse an enum member from its name or (for string enums) its value.
/// Matching ignores case, "-", "_" and blanks. Unknown values give `fallback`.
E parseEnum(E)(string value, E fallback) if (is(E == enum)) {
  auto wanted = normalize(value);
  if (wanted.length == 0)
    return fallback;
  foreach (m; [EnumMembers!E]) {
    if (normalize(m.to!string) == wanted)
      return m;
    static if (is(Unqual!(OriginalType!E) == string))
      if (normalize(cast(string) m) == wanted)
        return m;
  }
  return fallback;
}

/// True if `value` names a member of E.
bool isEnumText(E)(string value) if (is(E == enum)) {
  auto wanted = normalize(value);
  foreach (m; [EnumMembers!E]) {
    if (normalize(m.to!string) == wanted)
      return true;
    static if (is(Unqual!(OriginalType!E) == string))
      if (normalize(cast(string) m) == wanted)
        return true;
  }
  return false;
}

///
unittest {
  enum Color { red, darkBlue, auto_ }
  enum Kind : string { apiGateway = "api-gateway", istio = "istio" }

  assert(enumText(Color.auto_) == "auto");
  assert(enumText(Kind.apiGateway) == "api-gateway");
  immutable Kind[] kinds = [Kind.apiGateway];
  assert(enumText(kinds[0]) == "api-gateway"); // qualified enum types
  assert(isEnumText!(immutable Kind)("api-gateway"));
  assert(parseEnum!Color("DARK-blue", Color.red) == Color.darkBlue);
  assert(parseEnum!Color("auto", Color.red) == Color.auto_);
  assert(parseEnum!Color("nope", Color.red) == Color.red);
  assert(parseEnum!Kind("api-gateway", Kind.istio) == Kind.apiGateway);
  assert(parseEnum!Kind("apiGateway", Kind.istio) == Kind.apiGateway);
  assert(isEnumText!Kind("ISTIO") && !isEnumText!Kind("x"));
  assert(enumTexts!Color == ["red", "darkBlue", "auto"]);
}
