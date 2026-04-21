/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.match_group;

// import uim.platform.data.quality.domain.types;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// A group of records identified as potential duplicates.
struct MatchGroup {
  mixin TenantEntity!(MatchGroupId);

  DatasetId datasetId;
  MatchStrategy strategy;
  MatchCandidate[] candidates;
  RecordId survivorRecordId; // golden / master record
  bool resolved;
  long detectedAt;
  long resolvedAt;

  Json toJson() const {
    return Json.entityToJson
      .set("datasetId", datasetId)
      .set("strategy", strategy.to!string)
      .set("resolved", resolved)
      .set("detectedAt", detectedAt)
      .set("resolvedAt", resolvedAt)
      .set("survivorRecordId", survivorRecordId)
      .set("candidates", candidates.map!(c => c.toJson()).array);
  }
}

/// A candidate record within a match group.
struct MatchCandidate {
  RecordId recordId;
  double score; // 0.0 - 100.0
  MatchConfidence confidence;
  FieldMatch[] fieldMatches; // per-field match details
  bool isSurvivor; // chosen as golden record

  Json toJson() const {
    return Json.emptyObject
      .set("recordId", recordId)
      .set("score", score)
      .set("confidence", confidence.to!string)
      .set("isSurvivor", isSurvivor)
      .set("fieldMatches", fieldMatches.map!(fm => fm.toJson()).array);
  }
}

/// Per-field match detail for duplicate detection.
struct FieldMatch {
  string fieldName;
  string valueA;
  string valueB;
  double similarity; // 0.0 - 1.0
  MatchStrategy matchMethod; // e.g. exact, fuzzy, etc.

  Json toJson() const {
    return Json.emptyObject
      .set("fieldName", fieldName)
      .set("valueA", valueA)
      .set("valueB", valueB)
      .set("similarity", similarity)
      .set("matchMethod", matchMethod.to!string);
  }
}
