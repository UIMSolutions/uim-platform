module uim.platform.data_quality.domain.enumerations;
/// Data quality validation rule type.
enum RuleType {
  required, // field must not be empty
  format_, // regex / pattern match
  range, // min/max numeric range
  enumeration, // value must be in a set
  length, // min/max string length
  crossField, // comparison between fields
  custom, // user-defined expression
  referenceData, // lookup against reference table
}
RuleType toRuleType(string s) {
  import std.uni : toLower;
  switch (s.toLower()) {
    case "required": return RuleType.required;
    case "format": return RuleType.format_;
    case "range": return RuleType.range;
    case "enumeration": return RuleType.enumeration;
    case "length": return RuleType.length;
    case "crossfield": return RuleType.crossField;
    case "custom": return RuleType.custom;
    case "referencedata": return RuleType.referenceData;
    default: return RuleType.custom; // default
  }
}
/// Severity of a rule violation.
enum RuleSeverity {
  info,
  warning,
  error,
  critical,
}
RuleSeverity toRuleSeverity(string s) {
  import std.uni : toLower;
  switch (s.toLower()) {
    case "info": return RuleSeverity.info;
    case "warning": return RuleSeverity.warning;
    case "error": return RuleSeverity.error;
    case "critical": return RuleSeverity.critical;
    default: return RuleSeverity.error; // default
  }
}
/// Status of a validation rule.
enum RuleStatus {
  draft,
  active,
  inactive,
}
RuleStatus toRuleStatus(string s) {
  import std.uni : toLower;
  switch (s.toLower()) {
    case "active": return RuleStatus.active;
    case "inactive": return RuleStatus.inactive;
    case "draft": return RuleStatus.draft;
    default: return RuleStatus.draft; // default
  }
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
  if (score >= 95.0) return QualityRating.excellent;
  else if (score >= 80.0) return QualityRating.good;
  else if (score >= 60.0) return QualityRating.fair;
  else if (score >= 40.0) return QualityRating.poor;
  else return QualityRating.critical;
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
    case "pending": return JobStatus.pending;
    case "running": return JobStatus.running;
    case "completed": return JobStatus.completed;
    case "failed": return JobStatus.failed;
    case "cancelled": return JobStatus.cancelled;
    default: return JobStatus.pending; // default
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
    case "residential": return AddressType.residential;
    case "business": return AddressType.business;
    case "pobox": return AddressType.poBox;
    case "military": return AddressType.military;
    default: return AddressType.unknown; // default
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
    case "verified": return AddressQuality.verified;
    case "corrected": return AddressQuality.corrected;
    case "partial": return AddressQuality.partial;
    case "unverifiable": return AddressQuality.unverifiable;
    case "invalid": return AddressQuality.invalid;
    default: return AddressQuality.unverifiable; // default
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
  if (score >= 100.0) return MatchConfidence.exact;
  else if (score >= 90.0) return MatchConfidence.high;
  else if (score >= 70.0) return MatchConfidence.medium;
  else if (score >= 50.0) return MatchConfidence.low;
  else return MatchConfidence.noMatch;
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
    case "exact": return MatchStrategy.exact;
    case "fuzzy": return MatchStrategy.fuzzy;
    case "phonetic": return MatchStrategy.phonetic;
    case "composite": return MatchStrategy.composite;
    default: return MatchStrategy.exact; // default
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
    case "string": return ProfiledDataType.string_;
    case "integer": return ProfiledDataType.integer;
    case "float": return ProfiledDataType.float_;
    case "date": return ProfiledDataType.date;
    case "boolean": return ProfiledDataType.boolean_;
    case "email": return ProfiledDataType.email;
    case "phone": return ProfiledDataType.phone;
    case "postalcode": return ProfiledDataType.postalCode;
    default: return ProfiledDataType.unknown; // default
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
    case "none": return CleansingAction.none;
    case "trimmed": return CleansingAction.trimmed;
    case "normalized": return CleansingAction.normalized;
    case "corrected": return CleansingAction.corrected;
    case "standardized": return CleansingAction.standardized;
    case "enriched": return CleansingAction.enriched;
    case "removed": return CleansingAction.removed;
    case "defaulted": return CleansingAction.defaulted;
    default: return CleansingAction.none; // default
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
    case "rooftop": return GeocodePrecision.rooftop;
    case "interpolated": return GeocodePrecision.interpolated;
    case "centroid": return GeocodePrecision.centroid;
    case "postalcode": return GeocodePrecision.postalCode;
    case "city": return GeocodePrecision.city;
    case "country": return GeocodePrecision.country;
    case "none": return GeocodePrecision.none;
    default: return GeocodePrecision.none; // default
  }
}