/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.services.validation_engine;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_rule;
import uim.platform.data.quality.domain.entities.validation_result;

// import std.regex;
// import std.conv : to;
// import std.uni : toLower;

/// Domain service - evaluates validation rules against record field values.
class ValidationEngine {
  /// Validate a set of field values against applicable rules.
  ValidationResult validate(RecordId recordId, TenantId tenantId,
      DatasetId datasetId, string[string] fieldValues, ValidationRule[] rules) {
    ValidationResult result;
    result.recordId = recordId;
    result.tenantId = tenantId;
    result.datasetId = datasetId;
    result.totalRulesChecked = cast(int) rules.length;

    int passed = 0;
    int failed = 0;

    foreach (ref rule; rules) {
      if (rule.status != RuleStatus.active)
        continue;

      auto value = rule.fieldName in fieldValues;
      string fieldVal = value ? *value : "";

      auto violation = evaluateRule(rule, fieldVal, fieldValues);
      if (violation.ruleId.length > 0) {
        result.violations ~= violation;
        ++failed;
      }
      else
      {
        ++passed;
      }
    }

    result.passedRules = passed;
    result.failedRules = failed;
    result.totalRulesChecked = passed + failed;

    if (result.totalRulesChecked > 0)
      result.qualityScore = (cast(double) passed / result.totalRulesChecked) * 100.0;
    else
      result.qualityScore = 100.0;

    // import std.datetime.systime : Clock;
    result.validatedAt = Clock.currStdTime();

    return result;
  }

  private RuleViolation evaluateRule(ref const ValidationRule rule,
      string fieldValue, string[string] allFields) {
    RuleViolation empty;

    final switch (rule.ruleType) {
    case RuleType.required:
      if (fieldValue.length == 0)
        return makeViolation(rule,
            fieldValue, "Field is required");
      break;

    case RuleType.format_:
      if (fieldValue.length > 0 && rule.pattern.length > 0) {
        try
        {
          auto r = regex(rule.pattern);
          if (matchFirst(fieldValue, r).empty)
            return makeViolation(rule, fieldValue, "Value does not match pattern: " ~ rule.pattern);
        }
        catch (Exception)
        {
          return makeViolation(rule, fieldValue, "Invalid rule pattern");
        }
      }
      break;

    case RuleType.range:
      if (fieldValue.length > 0) {
        try
        {
          auto val = fieldValue.to!double;
          if (rule.minValue.length > 0 && val < rule.minValue.to!double)
            return makeViolation(rule, fieldValue, "Value below minimum: " ~ rule.minValue);
          if (rule.maxValue.length > 0 && val > rule.maxValue.to!double)
            return makeViolation(rule, fieldValue, "Value above maximum: " ~ rule.maxValue);
        }
        catch (Exception)
        {
          return makeViolation(rule, fieldValue, "Value is not numeric");
        }
      }
      break;

    case RuleType.enumeration:
      if (fieldValue.length > 0 && rule.allowedValues.length > 0) {
        bool found = false;
        foreach (av; rule.allowedValues)
          if (av == fieldValue)
          {
            found = true;
            break;
          }
        if (!found)
          return makeViolation(rule, fieldValue, "Value not in allowed set");
      }
      break;

    case RuleType.length:
      if (fieldValue.length > 0) {
        try
        {
          if (rule.minValue.length > 0 && fieldValue.length < rule.minValue.to!size_t)
            return makeViolation(rule, fieldValue,
                "Value too short, minimum length: " ~ rule.minValue);
          if (rule.maxValue.length > 0 && fieldValue.length > rule.maxValue.to!size_t)
            return makeViolation(rule, fieldValue,
                "Value too long, maximum length: " ~ rule.maxValue);
        }
        catch (Exception)
        {
          return makeViolation(rule, fieldValue, "Invalid length constraint");
        }
      }
      break;

    case RuleType.crossField:
      if (rule.crossFieldName.length > 0) {
        auto other = rule.crossFieldName in allFields;
        string otherVal = other ? *other : "";
        if (fieldValue != otherVal)
          return makeViolation(rule, fieldValue,
              "Value does not match field: " ~ rule.crossFieldName);
      }
      break;

    case RuleType.custom:
      // Custom expression evaluation - placeholder for extensibility
      break;

    case RuleType.referenceData:
      // Reference data lookup - placeholder for extensibility
      break;
    }

    return empty;
  }

  private static RuleViolation makeViolation(ref const ValidationRule rule,
      string fieldValue, string message) {
    RuleViolation v;
    v.ruleId = rule.id;
    v.ruleName = rule.name;
    v.fieldName = rule.fieldName;
    v.fieldValue = fieldValue;
    v.severity = rule.severity;
    v.message = message;
    return v;
  }
}
