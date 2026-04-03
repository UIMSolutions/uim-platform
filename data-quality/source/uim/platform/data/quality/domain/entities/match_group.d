module uim.platform.data.quality.domain.entities.match_group;

import uim.platform.data.quality.domain.types;

/// A group of records identified as potential duplicates.
struct MatchGroup
{
    MatchGroupId id;
    TenantId tenantId;
    DatasetId datasetId;
    MatchStrategy strategy;
    MatchCandidate[] candidates;
    RecordId survivorRecordId;  // golden / master record
    bool resolved;
    long detectedAt;
    long resolvedAt;
}

/// A candidate record within a match group.
struct MatchCandidate
{
    RecordId recordId;
    double score;               // 0.0 - 100.0
    MatchConfidence confidence;
    FieldMatch[] fieldMatches;  // per-field match details
    bool isSurvivor;            // chosen as golden record
}

/// Per-field match detail for duplicate detection.
struct FieldMatch
{
    string fieldName;
    string valueA;
    string valueB;
    double similarity;          // 0.0 - 1.0
    MatchStrategy matchMethod;
}
