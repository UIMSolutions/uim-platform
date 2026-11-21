/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Profiling statistics of one field of a dataset (latest profiling run).
/// The id is the field name.
module uim.platform.data_quality.domain.entities.column_profile;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct ColumnProfile {
  mixin TenantEntity!ColumnProfileId;

  DatasetId datasetId;
  int position; /// first appearance of the field in the dataset
  ColumnStats stats;
  long profiledAt;

  string fieldName() const {
    return stats.fieldName;
  }
}
