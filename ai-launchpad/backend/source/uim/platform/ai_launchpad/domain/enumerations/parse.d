/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Parsing of the string valued domain enumerations (case insensitive).
module uim.platform.ai_launchpad.domain.enumerations.parse;

import std.traits : EnumMembers;
import std.uni : icmp;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// All values of a string enum, in declaration order.
string[] domainEnumValues(E)() if (is(E : string) && is(E == enum)) {
  string[] values;
  static foreach (m; EnumMembers!E)
    values ~= cast(string) m;
  return values;
}

/// Parse a string enum value; throws AilpException.invalid.
E parseDomainEnum(E)(string text, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  auto t = text.strip;
  static foreach (m; EnumMembers!E)
    if (icmp(cast(string) m, t) == 0)
      return m;
  throw AilpException.invalid("Invalid " ~ field ~ " '" ~ text ~ "' (allowed: " ~ domainEnumValues!E.join(", ") ~ ")");
}

/// Parse or fall back to a default (empty text → default).
E parseDomainEnumOr(E)(string text, E fallback, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  return text.strip.length == 0 ? fallback : parseDomainEnum!E(text, field);
}

/// Parse, returning the fallback for unknown values (tolerant record reading).
E domainEnumOr(E)(string text, E fallback) if (is(E : string) && is(E == enum)) {
  try
    return parseDomainEnumOr!E(text, fallback);
  catch (AiLaunchpadException)
    return fallback;
}

///
unittest {
  assert(parseDomainEnum!ConnectionType("AICORE") == ConnectionType.aiCore);
  assert(parseDomainEnumOr!PromptStatus("", PromptStatus.draft) == PromptStatus.draft);
  assert(domainEnumOr!ExecutionStatus("garbage", ExecutionStatus.pending) == ExecutionStatus.pending);
  assert(failsWith(AilpErrorKind.invalid, () { parseDomainEnum!TileTargetType("mail"); }));
  assert(domainEnumValues!WorkspaceStatus == ["active", "inactive"]);
}
