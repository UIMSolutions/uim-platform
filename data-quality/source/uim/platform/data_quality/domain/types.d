module uim.platform.xyz.domain.types;

/// Unique identifier type aliases for type safety.
alias RecordId = string;
alias RuleId = string;
alias ProfileId = string;
alias DatasetId = string;
alias AddressId = string;
alias MatchGroupId = string;
alias CleansingJobId = string;
alias ProfileJobId = string;
alias TenantId = string;
alias UserId = string;

/// Data quality validation rule type.
enum RuleType
{
    required,          // field must not be empty
    format_,           // regex / pattern match
    range,             // min/max numeric range
    enumeration,       // value must be in a set
    length,            // min/max string length
    crossField,        // comparison between fields
    custom,            // user-defined expression
    referenceData,     // lookup against reference table
}

/// Severity of a rule violation.
enum RuleSeverity
{
    info,
    warning,
    error,
    critical,
}

/// Status of a validation rule.
enum RuleStatus
{
    active,
    inactive,
    draft,
}

/// Overall quality score rating.
enum QualityRating
{
    excellent,    // >= 95%
    good,         // >= 80%
    fair,         // >= 60%
    poor,         // >= 40%
    critical,     // < 40%
}

/// Status of a cleansing job.
enum JobStatus
{
    pending,
    running,
    completed,
    failed,
    cancelled,
}

/// Address type for cleansing.
enum AddressType
{
    residential,
    business,
    poBox,
    military,
    unknown,
}

/// Address quality level after cleansing.
enum AddressQuality
{
    verified,         // fully verified against postal DB
    corrected,        // corrected and verified
    partial,          // partially matched
    unverifiable,     // could not verify
    invalid,          // known invalid
}

/// Match confidence level for duplicate detection.
enum MatchConfidence
{
    exact,            // 100% match
    high,             // >= 90%
    medium,           // >= 70%
    low,              // >= 50%
    noMatch,          // < 50%
}

/// Match strategy for duplicate detection.
enum MatchStrategy
{
    exact,            // exact field comparison
    fuzzy,            // Levenshtein / Jaro-Winkler
    phonetic,         // Soundex / Metaphone
    composite,        // weighted multi-field
}

/// Data profiling column type detected.
enum ProfiledDataType
{
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

/// Cleansing action applied to a field.
enum CleansingAction
{
    none,
    trimmed,
    normalized,
    corrected,
    standardized,
    enriched,
    removed,
    defaulted,
}

/// Geocoding precision level.
enum GeocodePrecision
{
    rooftop,          // exact building
    interpolated,     // estimated along street
    centroid,         // center of area
    postalCode,       // postal code center
    city,             // city center
    country,          // country center
    none,             // could not geocode
}
