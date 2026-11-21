/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations. All are string enums: the stored and exposed
/// value is the member's string (stable across OData, REST, CLI and GUI).
module uim.platform.data_quality.domain.enumerations.quality;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// Kind of a validation rule.
enum RuleType : string {
  required = "required", /// the field must be present and not empty
  format = "format", /// the value must match a regular expression
  range = "range", /// numeric value within [minValue, maxValue]
  length = "length", /// text length within [minValue, maxValue]
  enumeration = "enumeration", /// the value must be one of allowedValues
  crossField = "crossField", /// comparison with another field (operator, default "eq")
  custom = "custom", /// expression "<field> <op> <value|$field>" must hold
  referenceData = "referenceData", /// the value must exist in a field of a reference dataset
  unique = "unique" /// the value must be unique within the dataset
}

/// Data quality dimension a rule type contributes to.
enum QualityDimension : string {
  completeness = "completeness",
  validity = "validity",
  uniqueness = "uniqueness",
  consistency = "consistency",
  accuracy = "accuracy"
}

QualityDimension dimensionOf(RuleType type) pure {
  final switch (type) {
  case RuleType.required:
    return QualityDimension.completeness;
  case RuleType.format, RuleType.range, RuleType.length, RuleType.enumeration:
    return QualityDimension.validity;
  case RuleType.crossField, RuleType.custom:
    return QualityDimension.consistency;
  case RuleType.referenceData:
    return QualityDimension.accuracy;
  case RuleType.unique:
    return QualityDimension.uniqueness;
  }
}

/// Severity of a rule violation (ordered).
enum RuleSeverity : string {
  info = "info",
  warning = "warning",
  error = "error",
  critical = "critical"
}

int severityRank(RuleSeverity s) pure {
  final switch (s) {
  case RuleSeverity.info:
    return 1;
  case RuleSeverity.warning:
    return 2;
  case RuleSeverity.error:
    return 3;
  case RuleSeverity.critical:
    return 4;
  }
}

/// Lifecycle of validation and cleansing rules. Only active rules run.
enum RuleStatus : string {
  draft = "draft",
  active = "active",
  inactive = "inactive"
}

/// Rating of a quality score.
enum QualityRating : string {
  excellent = "excellent", /// >= 95
  good = "good", /// >= 80
  fair = "fair", /// >= 60
  poor = "poor", /// >= 40
  critical = "critical" /// < 40
}

QualityRating ratingOf(double score) pure {
  if (score >= 95.0)
    return QualityRating.excellent;
  if (score >= 80.0)
    return QualityRating.good;
  if (score >= 60.0)
    return QualityRating.fair;
  if (score >= 40.0)
    return QualityRating.poor;
  return QualityRating.critical;
}

/// Lifecycle of a cleansing job.
enum JobStatus : string {
  pending = "pending",
  running = "running",
  completed = "completed",
  failed = "failed",
  cancelled = "cancelled"
}

bool isFinal(JobStatus s) pure {
  return s == JobStatus.completed || s == JobStatus.failed || s == JobStatus.cancelled;
}

/// Transformation of a cleansing rule.
enum CleansingAction : string {
  trim = "trim", /// strip leading/trailing white space
  collapseWhitespace = "collapseWhitespace", /// trim and collapse inner runs of white space
  upperCase = "upperCase",
  lowerCase = "lowerCase",
  titleCase = "titleCase",
  removeDiacritics = "removeDiacritics", /// "Müller" → "Muller", "ß" → "ss"
  replace = "replace", /// regex findPattern → replaceWith
  defaultValue = "defaultValue", /// set defaultValue if the field is missing or empty
  clear = "clear", /// remove the field
  standardizeCountry = "standardizeCountry", /// country names → ISO 3166 alpha-2
  enrich = "enrich" /// copy lookupValueField of the lookupDataset record whose lookupKeyField equals sourceField
}

/// Strategy of the duplicate detection.
enum MatchStrategy : string {
  exact = "exact", /// normalized values are equal
  fuzzy = "fuzzy", /// Jaro-Winkler similarity
  phonetic = "phonetic", /// Soundex codes are equal
  composite = "composite" /// 60 % fuzzy + 40 % phonetic
}

/// Confidence of a duplicate candidate.
enum MatchConfidence : string {
  exact = "exact", /// 100
  high = "high", /// >= 90
  medium = "medium", /// >= 70
  low = "low" /// below 70
}

MatchConfidence confidenceOf(double score) pure {
  if (score >= 100.0)
    return MatchConfidence.exact;
  if (score >= 90.0)
    return MatchConfidence.high;
  if (score >= 70.0)
    return MatchConfidence.medium;
  return MatchConfidence.low;
}

/// Data type detected by the profiler.
enum ProfiledType : string {
  empty = "empty",
  text = "text",
  integer = "integer",
  decimal = "decimal",
  boolean = "boolean",
  date = "date",
  email = "email",
  phone = "phone",
  mixed = "mixed"
}

/// Result quality of an address cleansing.
enum AddressQuality : string {
  verified = "verified", /// complete, plausible postal code, no changes needed
  corrected = "corrected", /// complete and plausible after corrections
  partial = "partial", /// street and city, but incomplete
  invalid = "invalid", /// the postal code does not fit the country format
  unverifiable = "unverifiable" /// not enough data
}

///
unittest {
  assert(dimensionOf(RuleType.unique) == QualityDimension.uniqueness);
  assert(severityRank(RuleSeverity.critical) > severityRank(RuleSeverity.error));
  assert(ratingOf(95) == QualityRating.excellent && ratingOf(39.9) == QualityRating.critical);
  assert(confidenceOf(100) == MatchConfidence.exact && confidenceOf(75) == MatchConfidence.medium);
  assert(isFinal(JobStatus.cancelled) && !isFinal(JobStatus.running));
}
