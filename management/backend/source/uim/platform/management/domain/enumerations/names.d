/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// External names of business enumerations.
///
/// D keywords force member names like `default_` or `deprecated_`; outside the
/// domain (JSON, OData, CLI) these are always written without the trailing "_".
module uim.platform.management.domain.enumerations.names;

import std.traits : EnumMembers, Unqual;
import uim.platform.management;

mixin(ShowModule!());

@safe:

/// The external name of an enum member ("default_" → "default").
string enumName(E)(E value) if (is(Unqual!E == enum)) {
  auto s = value.to!string;
  return s.length > 1 && s[$ - 1] == '_' ? s[0 .. $ - 1] : s;
}

/// All external names of an enum, in declaration order.
string[] enumNames(E)() if (is(E == enum)) {
  string[] names;
  foreach (m; [EnumMembers!E])
    names ~= enumName(m);
  return names;
}

/// Case-insensitive parse of an external (or internal) member name.
bool tryParseEnum(E)(string value, out E result) if (is(E == enum)) {
  auto v = value.strip.toLower;
  foreach (m; [EnumMembers!E]) {
    if (enumName(m).toLower == v || m.to!string.toLower == v) {
      result = m;
      return true;
    }
  }
  return false;
}

/// Parse with fallback (empty or unknown values give the fallback).
E parseEnum(E)(string value, E fallback) if (is(E == enum)) {
  E result;
  return tryParseEnum!E(value, result) ? result : fallback;
}

///
unittest {
  mixin(ShowTest!("enumName / parseEnum"));

  assert(enumName(DirectoryType.default_) == "default");
  assert(enumName(SubaccountStatus.moveInProgress) == "moveInProgress");
  assert(parseEnum!ServicePlanStatus("deprecated", ServicePlanStatus.active) == ServicePlanStatus.deprecated_);
  assert(parseEnum!LicenseType("TRIAL", LicenseType.enterprise) == LicenseType.trial);
  assert(parseEnum!LicenseType("nonsense", LicenseType.enterprise) == LicenseType.enterprise);

  EnvironmentType t;
  assert(tryParseEnum!EnvironmentType("kyma", t) && t == EnvironmentType.kyma);
  assert(!tryParseEnum!EnvironmentType("mainframe", t));
  assert(enumNames!PricingModel() == ["free", "subscription", "consumption", "byol"]);
}
