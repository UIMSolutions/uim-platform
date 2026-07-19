module uim.platform.data_quality.domain.enumerations;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
/// Data quality validation rule type.
enum RuleType : string{
  required = "required", // field must not be empty
  format_ = "format", // regex / pattern match
  range = "range", // min/max numeric range
  enumeration = "enumeration", // value must be in a set
  length = "length", // min/max string length
  crossField = "crossField", // comparison between fields
  custom = "custom", // user-defined expression
  referenceData = "referenceData", // lookup against reference table
}

RuleType toRuleType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "required":
    return RuleType.required;
  case "format":
    return RuleType.format_;
  case "range":
    return RuleType.range;
  case "enumeration":
    return RuleType.enumeration;
  case "length":
    return RuleType.length;
  case "crossfield":
    return RuleType.crossField;
  case "custom":
    return RuleType.custom;
  case "referencedata":
    return RuleType.referenceData;
  default:
    return RuleType.custom; // default
  }
}

RuleType[] toRuleTypes(string[] values) {
  return values.map!(toRuleType).array;
}

string toString(RuleType type) {
  return type.to!string;
}

string[] toStrings(RuleType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  assert("required".toRuleType == RuleType.required);
  assert("format".toRuleType == RuleType.format_);
  assert("range".toRuleType == RuleType.range);
  assert("enumeration".toRuleType == RuleType.enumeration);
  assert("length".toRuleType == RuleType.length);
  assert("crossField".toRuleType == RuleType.crossField);
  assert("custom".toRuleType == RuleType.custom);
  assert("referenceData".toRuleType == RuleType.referenceData);

  assert(toString(RuleType.required) == "required");
  assert(toString(RuleType.format_) == "format_");
  assert(toString(RuleType.range) == "range");
  assert(toString(RuleType.enumeration) == "enumeration");
  assert(toString(RuleType.length) == "length");
  assert(toString(RuleType.crossField) == "crossField");
  assert(toString(RuleType.custom) == "custom");
  assert(toString(RuleType.referenceData) == "referenceData");

  assert(["required", "format", "range"].toRuleTypes ==
      [RuleType.required, RuleType.format_, RuleType.range]);
  assert(toString([RuleType.required, RuleType.format_, RuleType.range]) ==
      ["required", "format_", "range"]);
}

/// Severity of a rule violation.
enum RuleSeverity {
  info,
  warning,
  error,
  critical,
}

RuleSeverity toRuleSeverity(string value) {
  mixin(EnumSwitch("RuleSeverity", "info"));
}

RuleSeverity[] toRuleSeverities(string[] values) {
  return values.map!(toRuleSeverity).array;
}

string toString(RuleSeverity severity) {
  return severity.to!string;
}

string[] toStrings(RuleSeverity[] severities) {
  return severities.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("RuleSeverity"));

  assert("info".toRuleSeverity == RuleSeverity.info);
  assert("warning".toRuleSeverity == RuleSeverity.warning);
  assert("error".toRuleSeverity == RuleSeverity.error);
  assert("critical".toRuleSeverity == RuleSeverity.critical);

  assert("some".toRuleSeverity == RuleSeverity.info); // default case
  assert("".toRuleSeverity == RuleSeverity.info); // default case

  assert(toString(RuleSeverity.info) == "info");
  assert(toString(RuleSeverity.warning) == "warning");
  assert(toString(RuleSeverity.error) == "error");
  assert(toString(RuleSeverity.critical) == "critical");

  assert(["info", "warning", "error"].toRuleSeverities ==
      [RuleSeverity.info, RuleSeverity.warning, RuleSeverity.error]);
  assert(toString([RuleSeverity.info, RuleSeverity.warning, RuleSeverity.error]) ==
      ["info", "warning", "error"]);
}

/// Status of a validation rule.
enum RuleStatus {
  draft,
  active,
  inactive,
}

RuleStatus toRuleStatus(string value) {
  mixin(EnumSwitch("RuleStatus", "draft"));
}
RuleStatus[] toRuleStatuses(string[] values) {
  return values.map!(toRuleStatus).array;
}
string toString(RuleStatus status) {
  return status.to!string;
}
string[] toStrings(RuleStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("RuleStatus"));

  assert("draft".toRuleStatus == RuleStatus.draft);
  assert("active".toRuleStatus == RuleStatus.active);
  assert("inactive".toRuleStatus == RuleStatus.inactive);

  assert("some".toRuleStatus == RuleStatus.draft); // default case
  assert("".toRuleStatus == RuleStatus.draft); // default case

  assert(toString(RuleStatus.draft) == "draft");
  assert(toString(RuleStatus.active) == "active");
  assert(toString(RuleStatus.inactive) == "inactive");

  assert(["draft", "active", "inactive"].toRuleStatuses ==
      [RuleStatus.draft, RuleStatus.active, RuleStatus.inactive]);
  assert(toString([RuleStatus.draft, RuleStatus.active, RuleStatus.inactive]) ==
      ["draft", "active", "inactive"]);
}

/// Overall quality score rating.
enum QualityRating {
  excellent, // >= 95%
  good, // >= 80%
  fair, // >= 60%
  poor, // >= 40%
  critical, // < 40%
}

QualityRating toQualityRating(double score) {
  if (score >= 95.0)
    return QualityRating.excellent;
  else if (score >= 80.0)
    return QualityRating.good;
  else if (score >= 60.0)
    return QualityRating.fair;
  else if (score >= 40.0)
    return QualityRating.poor;
  else
    return QualityRating.critical;
}

/// Status of a cleansing job.
enum JobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

JobStatus toJobStatus(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "pending":
    return JobStatus.pending;
  case "running":
    return JobStatus.running;
  case "completed":
    return JobStatus.completed;
  case "failed":
    return JobStatus.failed;
  case "cancelled":
    return JobStatus.cancelled;
  default:
    return JobStatus.pending; // default
  }
}
/// Address type for cleansing.
enum AddressType {
  residential,
  business,
  poBox,
  military,
  unknown,
}

AddressType toAddressType(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "residential":
    return AddressType.residential;
  case "business":
    return AddressType.business;
  case "pobox":
    return AddressType.poBox;
  case "military":
    return AddressType.military;
  default:
    return AddressType.unknown; // default
  }
}
/// Address quality level after cleansing.
enum AddressQuality {
  verified, // fully verified against postal DB
  corrected, // corrected and verified
  partial, // partially matched
  unverifiable, // could not verify
  invalid, // known invalid
}

AddressQuality toAddressQuality(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "verified":
    return AddressQuality.verified;
  case "corrected":
    return AddressQuality.corrected;
  case "partial":
    return AddressQuality.partial;
  case "unverifiable":
    return AddressQuality.unverifiable;
  case "invalid":
    return AddressQuality.invalid;
  default:
    return AddressQuality.unverifiable; // default
  }
}
/// Match confidence level for duplicate detection.
enum MatchConfidence {
  exact, // 100% match
  high, // >= 90%
  medium, // >= 70%
  low, // >= 50%
  noMatch, // < 50%
}

MatchConfidence toMatchConfidence(double score) {
  if (score >= 100.0)
    return MatchConfidence.exact;
  else if (score >= 90.0)
    return MatchConfidence.high;
  else if (score >= 70.0)
    return MatchConfidence.medium;
  else if (score >= 50.0)
    return MatchConfidence.low;
  else
    return MatchConfidence.noMatch;
}
/// Match strategy for duplicate detection.
enum MatchStrategy {
  exact, // exact field comparison
  fuzzy, // Levenshtein / Jaro-Winkler
  phonetic, // Soundex / Metaphone
  composite, // weighted multi-field
}

MatchStrategy toMatchStrategy(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "exact":
    return MatchStrategy.exact;
  case "fuzzy":
    return MatchStrategy.fuzzy;
  case "phonetic":
    return MatchStrategy.phonetic;
  case "composite":
    return MatchStrategy.composite;
  default:
    return MatchStrategy.exact; // default
  }
}
/// Data profiling column type detected.
enum ProfiledDataType {
  string_,
  integer,
  float_,
  date,
  boolean_,
  email,
  phone,
  postalCode,
  unknown,
}

ProfiledDataType toProfiledDataType(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "string":
    return ProfiledDataType.string_;
  case "integer":
    return ProfiledDataType.integer;
  case "float":
    return ProfiledDataType.float_;
  case "date":
    return ProfiledDataType.date;
  case "boolean":
    return ProfiledDataType.boolean_;
  case "email":
    return ProfiledDataType.email;
  case "phone":
    return ProfiledDataType.phone;
  case "postalcode":
    return ProfiledDataType.postalCode;
  default:
    return ProfiledDataType.unknown; // default
  }
}
/// Cleansing action applied to a field.
enum CleansingAction {
  none,
  trimmed,
  normalized,
  corrected,
  standardized,
  enriched,
  removed,
  defaulted,
}

CleansingAction toCleansingAction(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "none":
    return CleansingAction.none;
  case "trimmed":
    return CleansingAction.trimmed;
  case "normalized":
    return CleansingAction.normalized;
  case "corrected":
    return CleansingAction.corrected;
  case "standardized":
    return CleansingAction.standardized;
  case "enriched":
    return CleansingAction.enriched;
  case "removed":
    return CleansingAction.removed;
  case "defaulted":
    return CleansingAction.defaulted;
  default:
    return CleansingAction.none; // default
  }
}

/// Geocoding precision level.
enum GeocodePrecision {
  rooftop, // exact building
  interpolated, // estimated along street
  centroid, // center of area
  postalCode, // postal code center
  city, // city center
  country, // country center
  none, // could not geocode
}

GeocodePrecision toGeocodePrecision(string s) {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "rooftop":
    return GeocodePrecision.rooftop;
  case "interpolated":
    return GeocodePrecision.interpolated;
  case "centroid":
    return GeocodePrecision.centroid;
  case "postalcode":
    return GeocodePrecision.postalCode;
  case "city":
    return GeocodePrecision.city;
  case "country":
    return GeocodePrecision.country;
  case "none":
    return GeocodePrecision.none;
  default:
    return GeocodePrecision.none; // default
  }
}
