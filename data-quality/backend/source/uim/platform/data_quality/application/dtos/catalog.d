/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of the data catalog (datasets, records).
module uim.platform.data_quality.application.dtos.catalog;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct CreateDatasetRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  string name;
  string description;
  string category;
}

struct UpdateDatasetRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Patch!string name;
  Patch!string description;
  Patch!string category;
}

struct CreateRecordRequest {
  TenantId tenantId;
  UserId actor;
  DatasetId datasetId;
  string id; /// "" = generated
  FieldValue[] fields;
}

struct UpdateRecordRequest {
  TenantId tenantId;
  UserId actor;
  DatasetId datasetId;
  string id;
  FieldValue[] fields;
  bool merge; /// true: set the given fields, keep the others; false: replace all fields
}

/// An ad-hoc record (bulk import, stateless checks).
struct InlineRecord {
  string id;
  FieldValue[] fields;
}

struct ImportRecordsRequest {
  TenantId tenantId;
  UserId actor;
  DatasetId datasetId;
  InlineRecord[] records;
  bool createDataset; /// create the dataset if it does not exist
  bool replaceExisting = true; /// overwrite records with the same id (else skip them)
  bool validate = true; /// validate the dataset afterwards
}

struct ImportResult {
  string datasetId;
  bool datasetCreated;
  size_t created;
  size_t updated;
  size_t skipped;
  bool validated;
  ValidationRunResult validation;
}
