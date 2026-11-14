/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.enumerations.risk_level;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Risk level determined by risk-based authentication (ordered low → critical).
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

RiskLevel toRiskLevel(string value) {
  mixin(EnumSwitch("RiskLevel", "low"));
}

RiskLevel[] toRiskLevels(string[] values)
  => values.map!toRiskLevel.array;

string toString(RiskLevel value)
  => value.to!string;

string[] toString(RiskLevel[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("RiskLevel"));

  assert("high".toRiskLevel == RiskLevel.high);
  assert("".toRiskLevel == RiskLevel.low);
  assert(RiskLevel.critical > RiskLevel.high);
  assert([RiskLevel.low, RiskLevel.high].toString == ["low", "high"]);
}
