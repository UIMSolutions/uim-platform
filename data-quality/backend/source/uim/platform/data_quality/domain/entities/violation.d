/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A rule violation of a record found by the latest validation. The id is
/// "<recordId>:<ruleId>" (one violation per record and rule).
module uim.platform.data_quality.domain.entities.violation;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct Violation {
  mixin TenantEntity!ViolationId;

  DatasetId datasetId;
  RecordId recordId;
  ValidationRuleId ruleId;
  string ruleName;
  RuleType ruleType;
  string fieldName;
  string fieldValue;
  RuleSeverity severity = RuleSeverity.error;
  string message;
  string suggestedValue; /// auto-correction hint ("" = none)

  QualityDimension dimension() const {
    return dimensionOf(ruleType);
  }

  /// Info violations are reported, but do not reduce the quality scores.
  bool affectsScore() const {
    return severity != RuleSeverity.info;
  }

  static string idFor(string recordId, string ruleId) pure {
    return recordId ~ ":" ~ ruleId;
  }
}

///
unittest {
  Violation v;
  v.ruleType = RuleType.referenceData;
  assert(v.dimension == QualityDimension.accuracy && v.affectsScore);
  v.severity = RuleSeverity.info;
  assert(!v.affectsScore);
  assert(Violation.idFor("c1", "r1") == "c1:r1");
}
