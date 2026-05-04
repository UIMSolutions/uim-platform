/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.data_profile;

// import uim.platform.data.quality.domain.types;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// Profile analysis result for a dataset.
struct DataProfile {
  mixin TenantEntity!(DataProfileId);

  
  DatasetId datasetId;
  string datasetName;
  long totalRecords;
  long profiledRecords;
  ColumnProfile[] columns;
  double overallQualityScore; // 0.0 - 100.0
  QualityRating rating;
  long profiledAt;
  long duration; // profiling time in ms

  Json toJson() const {
    return entityToJson
      .set("datasetId", datasetId)
      .set("datasetName", datasetName)
      .set("totalRecords", totalRecords)
      .set("profiledRecords", profiledRecords)
      .set("columns", columns)
      .set("overallQualityScore", overallQualityScore)
      .set("rating", rating.to!string)
      .set("profiledAt", profiledAt)
      .set("duration", duration);
  }
}

/// Profiling statistics for a single column / field.
struct ColumnProfile {
  string fieldName;
  ProfiledDataType detectedType;
  long totalValues;
  long nullCount;
  long emptyCount;
  long uniqueCount;
  long duplicateCount;
  double completeness; // 0.0 - 100.0 (non-null %)
  double uniqueness; // 0.0 - 100.0
  double validity; // 0.0 - 100.0 (passes format rules)
  string minValue;
  string maxValue;
  string meanValue;
  string medianValue;
  string modeValue;
  long minLength;
  long maxLength;
  double avgLength;
  string[] topValues; // most frequent values
  string[] patternDistribution; // discovered patterns

  Json toJson() const {
    return Json()
      .set("fieldName", fieldName)
      .set("detectedType", detectedType.to!string)
      .set("totalValues", totalValues)
      .set("nullCount", nullCount)
      .set("emptyCount", emptyCount)
      .set("uniqueCount", uniqueCount)
      .set("duplicateCount", duplicateCount)
      .set("completeness", completeness)
      .set("uniqueness", uniqueness)
      .set("validity", validity)
      .set("minValue", minValue)
      .set("maxValue", maxValue)
      .set("meanValue", meanValue)
      .set("medianValue", medianValue)
      .set("modeValue", modeValue)
      .set("minLength", minLength)
      .set("maxLength", maxLength)
      .set("avgLength", avgLength)
      .set("topValues", topValues)
      .set("patternDistribution", patternDistribution);
  }
}
