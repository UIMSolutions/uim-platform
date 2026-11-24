/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the retention checks.
module uim.platform.data_retention.ports.usecases.checks;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IRetentionChecks {
  /// Block data subjects past their end of purpose, mark those past their
  /// end of retention for destruction (or only count: simulate).
  EndOfPurposeCheckResult checkEndOfPurpose(EndOfPurposeCheckRequest r);
  /// The dates a reference date would lead to under the rules of a purpose.
  RetentionEvaluation simulate(SimulationRequest r);
}
