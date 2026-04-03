/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.validation_result;

import uim.platform.data.quality.domain.types;

/// Result of running validation rules against a single record.
struct ValidationResult
{
  RecordId recordId;
  TenantId tenantId;
  DatasetId datasetId;
  RuleViolation[] violations;
  int totalRulesChecked;
  int passedRules;
  int failedRules;
  double qualityScore; // 0.0 - 100.0
  long validatedAt;
}

/// A single rule violation found during validation.
struct RuleViolation
{
  RuleId ruleId;
  string ruleName;
  string fieldName;
  string fieldValue;
  RuleSeverity severity;
  string message;
  string suggestedValue; // auto-correction hint
}
