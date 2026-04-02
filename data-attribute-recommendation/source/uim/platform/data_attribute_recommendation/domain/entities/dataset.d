module domain.entities.dataset;

import domain.types;

/// A training dataset containing column definitions and data records
/// used to train attribute recommendation models.
struct Dataset
{
  DatasetId id;
  TenantId tenantId;
  string name;
  string description;
  DatasetStatus status = DatasetStatus.draft;
  DataType dataType = DataType.product;
  string columnDefinitions; // JSON: [{name, dataType, isTarget, isFeature}]
  long rowCount;
  string validationMessage;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
