/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A configurable validation rule. It applies to the datasets matching
/// datasetPattern (glob, "" = all) and checks one field. Only active rules
/// run; lower priority values run first.
///
/// Parameters by type:
///   required       —
///   format         pattern (regular expression; anchor with ^…$ for a full match)
///   range          minValue / maxValue (numbers, either may be empty)
///   length         minValue / maxValue (characters)
///   enumeration    allowedValues (caseSensitive)
///   crossField     crossFieldName, operator (eq ne lt le gt ge, default eq)
///   custom         expression, e.g. "country == DE => postalCode matches ^[0-9]{5}$"
///   referenceData  referenceDataset, referenceField
///   unique         — (checked across the dataset)
module uim.platform.data_quality.domain.entities.validation_rule;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum string[] comparisonOperators = ["eq", "ne", "lt", "le", "gt", "ge"];

struct ValidationRule {
  mixin TenantEntity!ValidationRuleId;

  string name;
  string description;
  string datasetPattern; /// glob, "" = every dataset
  string fieldName;
  RuleType ruleType = RuleType.required;
  RuleSeverity severity = RuleSeverity.error;
  RuleStatus status = RuleStatus.draft;

  string pattern;
  string minValue;
  string maxValue;
  string[] allowedValues;
  bool caseSensitive = true;
  string crossFieldName;
  string operator = "eq";
  string expression;
  string referenceDataset;
  string referenceField;

  string category; /// grouping label (e.g. "address", "contact")
  int priority = 100; /// execution order (lower first)

  bool isActive() const {
    return status == RuleStatus.active;
  }

  bool appliesTo(DatasetId dataset) const {
    return datasetMatches(datasetPattern, dataset.value);
  }

  QualityDimension dimension() const {
    return dimensionOf(ruleType);
  }

  void validate() const @trusted {
    requireText(name, "Rule name");
    requireMaxLength(name, 256, "Rule name");
    requireMaxLength(description, 5000, "Description");
    requireMaxLength(datasetPattern, 128, "Dataset pattern");
    if (ruleType != RuleType.custom || fieldName.length > 0)
      requireFieldName(fieldName);
    requireRange(priority, 0, 100_000, "Priority");

    final switch (ruleType) {
    case RuleType.required, RuleType.unique:
      break;
    case RuleType.format:
      requireText(pattern, "Pattern of a format rule");
      try
        regex(pattern);
      catch (Exception e)
        throw DataQualityException.invalid("Pattern '" ~ pattern ~ "' is not a valid regular expression");
      break;
    case RuleType.range:
      if (minValue.length == 0 && maxValue.length == 0)
        throw DataQualityException.invalid("A range rule needs minValue and/or maxValue");
      double lo = -double.infinity, hi = double.infinity;
      if (minValue.length && !parseNumber(minValue, lo))
        throw DataQualityException.invalid("minValue '" ~ minValue ~ "' is not a number");
      if (maxValue.length && !parseNumber(maxValue, hi))
        throw DataQualityException.invalid("maxValue '" ~ maxValue ~ "' is not a number");
      if (lo > hi)
        throw DataQualityException.invalid("minValue must not exceed maxValue");
      break;
    case RuleType.length:
      if (minValue.length == 0 && maxValue.length == 0)
        throw DataQualityException.invalid("A length rule needs minValue and/or maxValue");
      double lo = 0, hi = double.infinity;
      if (minValue.length && (!parseNumber(minValue, lo) || lo < 0 || lo != cast(long) lo))
        throw DataQualityException.invalid("minValue of a length rule must be a non-negative integer");
      if (maxValue.length && (!parseNumber(maxValue, hi) || hi < 0 || hi != cast(long) hi))
        throw DataQualityException.invalid("maxValue of a length rule must be a non-negative integer");
      if (lo > hi)
        throw DataQualityException.invalid("minValue must not exceed maxValue");
      break;
    case RuleType.enumeration:
      if (allowedValues.length == 0)
        throw DataQualityException.invalid("An enumeration rule needs allowedValues");
      break;
    case RuleType.crossField:
      requireFieldName(crossFieldName, "Cross field");
      if (crossFieldName == fieldName)
        throw DataQualityException.invalid("A cross field rule compares two different fields");
      if (!comparisonOperators.canFind(operator))
        throw DataQualityException.invalid("Operator '" ~ operator ~ "' is invalid (allowed: " ~ comparisonOperators.join(", ") ~ ")");
      break;
    case RuleType.custom:
      requireText(expression, "Expression of a custom rule");
      parseExpression(expression);
      break;
    case RuleType.referenceData:
      requireId(referenceDataset, "Reference dataset");
      requireFieldName(referenceField, "Reference field");
      break;
    }
  }
}

///
unittest {
  ValidationRule r;
  r.name = "Email format";
  r.fieldName = "email";
  r.ruleType = RuleType.format;
  r.pattern = "^[^@]+@[^@]+$";
  r.validate();
  r.pattern = "([";
  assert(failsWith(DqErrorKind.invalid, () { r.validate(); }));
  r.ruleType = RuleType.range;
  r.minValue = "10";
  r.maxValue = "1";
  assert(failsWith(DqErrorKind.invalid, () { r.validate(); }));
  r.ruleType = RuleType.custom;
  r.expression = "age >= 18";
  r.validate();
  assert(r.appliesTo(DatasetId("x")) && r.dimension == QualityDimension.consistency);
}
