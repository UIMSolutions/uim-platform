/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.entities.validation_result;
// import uim.platform.data_quality.domain.types;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
/// Result of running validation rules against a single record.
struct ValidationResult {
  mixin TenantEntity!ValidationResultId;

  RecordId recordId;
  DatasetId datasetId;
  RuleViolation[] violations;
  int totalRulesChecked;
  int passedRules;
  int failedRules;
  double qualityScore; // 0.0 - 100.0
  long validatedAt;

  Json toJson() const {
    auto violationsJson = Json.emptyArray;
    foreach (violation; violations) {
      violationsJson.add(violation.toJson());
    }

    return entityToJson()
      .set("recordId", recordId.value)
      .set("datasetId", datasetId.value)
      .set("violations", violationsJson)
      .set("totalRulesChecked", totalRulesChecked)
      .set("passedRules", passedRules)
      .set("failedRules", failedRules)
      .set("qualityScore", qualityScore)
      .set("validatedAt", validatedAt);
  }
}
/// A single rule violation found during validation.
struct RuleViolation {
  ValidationRuleId ruleId;
  string ruleName;
  string fieldName;
  string fieldValue;
  RuleSeverity severity;
  string message;
  string suggestedValue; // auto-correction hint

  Json toJson() const {
    return Json.emptyObject
      .set("ruleId", ruleId.value)
      .set("ruleName", ruleName)
      .set("fieldName", fieldName)
      .set("fieldValue", fieldValue)
      .set("severity", severity.to!string())
      .set("message", message)
      .set("suggestedValue", suggestedValue);
  }
}
