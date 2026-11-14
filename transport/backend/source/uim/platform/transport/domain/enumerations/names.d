/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Name ↔ enum conversion shared by all adapters.
///
/// D keywords force trailing underscores (export_, import_, delete_); the
/// external (JSON / OData / CLI) name drops it: ActionType.export_ ⇄ "export".
module uim.platform.transport.domain.enumerations.names;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// External name of an enum member ("export_" → "export").
string enumName(E)(E value) if (is(E == enum)) {
  auto s = value.to!string;
  return s.length > 1 && s[$ - 1] == '_' ? s[0 .. $ - 1] : s;
}

/// All external names of an enum, in declaration order.
string[] enumNames(E)() if (is(E == enum)) {
  string[] names;
  foreach (m; EnumMembers!E)
    names ~= enumName(m);
  return names;
}

/// Parse an external or internal name (case-insensitive). Returns false if unknown.
bool tryParseEnum(E)(string text, out E value) if (is(E == enum)) {
  auto t = text.strip;
  if (t.length == 0)
    return false;
  foreach (m; EnumMembers!E) {
    if (icmp(enumName(m), t) == 0 || icmp(m.to!string, t) == 0) {
      value = m;
      return true;
    }
  }
  return false;
}

/// Parse a name, falling back to a default for empty or unknown values.
E parseEnum(E)(string text, E fallback) if (is(E == enum)) {
  E value;
  return tryParseEnum!E(text, value) ? value : fallback;
}

/// Parse a name or throw a TransportException (code 400) listing the valid values.
E requireEnum(E)(string text, string what) if (is(E == enum)) {
  E value;
  if (!tryParseEnum!E(text, value))
    throw new TransportException(400, "invalid " ~ what ~ " '" ~ text ~ "' (expected one of: "
        ~ enumNames!E().join(", ") ~ ")");
  return value;
}
