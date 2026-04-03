/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.dataset;

import uim.platform.data.attribute_recommendation.domain.types;

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
