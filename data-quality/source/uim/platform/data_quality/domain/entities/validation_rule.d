/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.entities.validation_rule;

import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
/// A configurable data quality validation rule.
struct ValidationRule {
      mixin TenantEntity!ValidationRuleId;

  string name;
  string description;
  string datasetPattern; // target dataset / object type
  string fieldName; // target field
  RuleType ruleType;
  RuleSeverity severity = RuleSeverity.error;
  RuleStatus status = RuleStatus.draft;

  // Rule parameters
  string pattern; // regex for format_ rules
  string minValue; // range / length min
  string maxValue; // range / length max
  string[] allowedValues; // enumeration set
  string expression; // custom rule expression
  string referenceDataset; // reference data lookup target
  string crossFieldName; // for cross-field rules

  string category; // grouping label (e.g. "address", "contact")
  int priority; // execution order (lower = first)
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("datasetPattern", datasetPattern)
      .set("fieldName", fieldName)
      .set("ruleType", ruleType.to!string())
      .set("severity", severity.to!string())
      .set("status", status.to!string())
      .set("pattern", pattern)
      .set("minValue", minValue)
      .set("maxValue", maxValue)
      .set("allowedValues", allowedValues.toJson)
      .set("expression", expression)
      .set("referenceDataset", referenceDataset)
      .set("crossFieldName", crossFieldName)
      .set("category", category)
      .set("priority", priority);
  }
}
