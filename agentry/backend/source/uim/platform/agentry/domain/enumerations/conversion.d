/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic, allocation-light conversions between enum members and their
/// external (JSON / OData / CLI) representation.
///
/// For string based enums the external value is the member VALUE
/// (AppStatus.deprecated_ ↔ "deprecated"), otherwise the member NAME.
module uim.platform.agentry.domain.enumerations.conversion;

import std.traits : EnumMembers, OriginalType, Unqual;
import std.uni : sicmp;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// External value of an enum member.
string enumValue(E)(E value) if (is(E == enum)) {
  static if (is(Unqual!(OriginalType!(Unqual!E)) == string))
    return cast(string) value;
  else
    return value.to!string;
}

/// All external values of an enum, in declaration order.
string[] enumValues(E)() if (is(E == enum)) {
  string[] result;
  foreach (m; EnumMembers!E)
    result ~= enumValue(m);
  return result;
}

/// Parse an external value (case-insensitive). Returns false if unknown.
bool tryParseEnum(E)(string text, out E result) if (is(E == enum)) {
  foreach (m; EnumMembers!E) {
    if (sicmp(enumValue(m), text) == 0) {
      result = m;
      return true;
    }
  }
  return false;
}

/// Parse an external value, falling back to a default for unknown input.
E parseEnum(E)(string text, E fallback) if (is(E == enum)) {
  E result;
  return tryParseEnum!E(text, result) ? result : fallback;
}

/// True if text is a known external value of E.
bool isEnumValue(E)(string text) if (is(E == enum)) {
  E ignored;
  return tryParseEnum!E(text, ignored);
}
///
unittest {
  mixin(ShowTest!("enum conversion"));

  assert(enumValue(AppStatus.deprecated_) == "deprecated");
  assert(enumValue(SyncStatus.inProgress) == "inProgress");
  assert(parseEnum!AppStatus("DEPRECATED", AppStatus.draft) == AppStatus.deprecated_);
  assert(parseEnum!SyncStatus("inprogress", SyncStatus.pending) == SyncStatus.inProgress);
  assert(parseEnum!SyncStatus("bogus", SyncStatus.failed) == SyncStatus.failed);
  assert(isEnumValue!DeploymentScope("group"));
  assert(!isEnumValue!DeploymentScope("galaxy"));
  assert(enumValues!SyncDirection() == ["upload", "download", "bidirectional"]);
  const AppVersionStatus constStatus = AppVersionStatus.deprecated_;
  assert(enumValue(constStatus) == "deprecated");
}
