/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.quality_dashboard;

// import uim.platform.data.quality.domain.types;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// Aggregated data quality metrics for a tenant / dataset.
struct QualityDashboard {
  mixin TenantEntity!(QualityDashboardId);

  DatasetId datasetId;
  string datasetName;

  // Record-level metrics
  long totalRecords;
  long validRecords;
  long invalidRecords;
  long duplicateRecords;
  long cleansedRecords;

  // Score breakdown
  double overallScore; // 0.0 - 100.0
  double completenessScore; // % non-null fields
  double validityScore; // % passing validation
  double uniquenessScore; // % unique records
  double consistencyScore; // % consistent across rules
  double accuracyScore; // % verified (address etc.)

  QualityRating rating;

  // Rule execution summary
  int totalRules;
  int activeRules;
  int violationCount;
  RuleSeverityCount[] violationsBySeverity;

  // Trend
  QualityTrendPoint[] trend; // historical scores

  long computedAt;

  Json toJson() const {
    return entityToJson
      .set("datasetId", datasetId)
      .set("datasetName", datasetName)
      .set("totalRecords", totalRecords)
      .set("validRecords", validRecords)
      .set("invalidRecords", invalidRecords)
      .set("duplicateRecords", duplicateRecords)
      .set("cleansedRecords", cleansedRecords)
      .set("overallScore", overallScore)
      .set("completenessScore", completenessScore)
      .set("validityScore", validityScore)
      .set("uniquenessScore", uniquenessScore)
      .set("consistencyScore", consistencyScore)
      .set("accuracyScore", accuracyScore)
      .set("rating", rating.to!string)
      .set("totalRules", totalRules)
      .set("activeRules", activeRules)
      .set("violationCount", violationCount)
      .set("violationsBySeverity", violationsBySeverity)
      .set("trend", trend)
      .set("computedAt", computedAt);
  }
}

/// Count of violations per severity level.
struct RuleSeverityCount {
  RuleSeverity severity;
  int count;

  Json toJson() const {
    return Json()
      .set("severity", severity.to!string)
      .set("count", count);
  }
}

/// A historical quality score data point.
struct QualityTrendPoint {
  long timestamp;
  double score;
  long recordCount;

  Json toJson() const {
    return Json()
      .set("timestamp", timestamp)
      .set("score", score)
      .set("recordCount", recordCount);
  }
}
