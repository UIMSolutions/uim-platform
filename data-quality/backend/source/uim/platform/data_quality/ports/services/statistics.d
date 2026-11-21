/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the tenant statistics (KPI header of the Fiori app).
module uim.platform.data_quality.ports.services.statistics;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct DqStatistics {
  string tenantId;
  size_t datasets;
  size_t scoredDatasets;
  size_t records;
  size_t validatedRecords;
  size_t invalidRecords;
  size_t validationRules;
  size_t activeValidationRules;
  size_t violations;
  size_t criticalViolations;
  size_t errorViolations;
  size_t warningViolations;
  size_t cleansingRules;
  size_t activeCleansingRules;
  size_t cleansingJobs;
  size_t pendingJobs;
  size_t failedJobs;
  size_t matchGroups;
  size_t openMatchGroups;
  size_t duplicateRecords;
  size_t addresses;
  size_t verifiedAddresses;
  size_t invalidAddresses;
  double averageScore = 100; /// mean overall score of the scored datasets
  QualityRating rating = QualityRating.excellent;
  long computedAt;
}

interface IDqStatisticsService {
  DqStatistics compute(TenantId t);
}
