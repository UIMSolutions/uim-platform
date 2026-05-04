/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.data_record;

import uim.platform.data.attribute_recommendation.domain.types;

/// An individual record within a dataset, holding attribute key-value pairs
/// and optional ground-truth labels for supervised training.
struct DataRecord {
  mixin TenantEntity!(DataRecordId);

  DatasetId datasetId;
  string attributes; // JSON: key-value pairs of record attributes
  string labels; // JSON: ground-truth label values for target columns
  RecordStatus status = RecordStatus.pending;

  Json toJson() const {
      return entityToJson
          .set("datasetId", datasetId)
          .set("attributes", attributes)
          .set("labels", labels)
          .set("status", status);
  }
}
