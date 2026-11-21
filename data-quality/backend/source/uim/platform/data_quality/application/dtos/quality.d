/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of validation, profiling, duplicate detection
/// and scorecards.
module uim.platform.data_quality.application.dtos.quality;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct ValidationRunResult {
  string datasetId;
  size_t records;
  size_t validRecords;
  size_t invalidRecords;
  size_t violations;
  size_t rulesApplied;
  double averageScore = 100; /// mean record score
  QualityScores scores;
  long durationMillis;
}

struct InlineValidationResult {
  string recordId;
  RecordCheck check;
}

struct ProfileRunResult {
  string datasetId;
  size_t records;
  size_t columns;
  double completeness = 100; /// mean column completeness
  double uniqueness = 100; /// mean column uniqueness
  long durationMillis;
}

struct DetectDuplicatesRequest {
  TenantId tenantId;
  UserId actor;
  DatasetId datasetId;
  string[] matchFields;
  string strategy = "fuzzy";
  double threshold = 85;
}

struct DetectResult {
  string datasetId;
  size_t records;
  size_t groups;
  size_t duplicateRecords;
  string strategy;
  double threshold;
  long durationMillis;
}

struct ResolveMatchGroupRequest {
  TenantId tenantId;
  UserId actor;
  DatasetId datasetId;
  string id;
  string survivorRecordId; /// "" = the anchor record
  bool merge; /// fill empty survivor fields from the duplicates and delete them
}

struct ResolveResult {
  string datasetId;
  string matchGroupId;
  string survivorRecordId;
  size_t removedRecords;
  size_t mergedFields;
}

struct Scorecard {
  string datasetId;
  QualityScores scores;
  size_t records;
  size_t violations;
  size_t openDuplicates;
  long computedAt;
}
