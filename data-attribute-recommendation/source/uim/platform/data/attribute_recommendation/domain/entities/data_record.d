module uim.platform.data.attribute_recommendation.domain.entities.data_record;

import uim.platform.data.attribute_recommendation.domain.types;

/// An individual record within a dataset, holding attribute key-value pairs
/// and optional ground-truth labels for supervised training.
struct DataRecord
{
  DataRecordId id;
  DatasetId datasetId;
  TenantId tenantId;
  string attributes; // JSON: key-value pairs of record attributes
  string labels; // JSON: ground-truth label values for target columns
  RecordStatus status = RecordStatus.pending;
  UserId createdBy;
  long createdAt;
}
