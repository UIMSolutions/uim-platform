/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A point of the quality trend of a dataset: the scorecard at a moment
/// (taken after every validation run and on demand).
module uim.platform.data_quality.domain.entities.quality_snapshot;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct QualitySnapshot {
  mixin TenantEntity!SnapshotId;

  DatasetId datasetId;
  QualityScores scores;
  long recordCount;
  long violationCount;
  long takenAt;
}
