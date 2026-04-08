/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.data_profile;

import uim.platform.data.quality.domain.types;

/// Profile analysis result for a dataset.
struct DataProfile {
  ProfileId profileId;
  TenantId tenantId;
  DatasetId datasetId;
  string datasetName;
  long totalRecords;
  long profiledRecords;
  ColumnProfile[] columns;
  double overallQualityScore; // 0.0 - 100.0
  QualityRating rating;
  long profiledAt;
  long duration; // profiling time in ms
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
}
