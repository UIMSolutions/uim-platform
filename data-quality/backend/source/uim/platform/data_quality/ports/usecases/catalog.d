/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the data catalog: datasets and their records.
/// List operations take an empty dataset id to mean "all datasets".
module uim.platform.data_quality.ports.usecases.catalog;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IManageDatasets {
  Dataset createDataset(CreateDatasetRequest r);
  Dataset updateDataset(UpdateDatasetRequest r);
  Dataset getDataset(TenantId t, DatasetId id);
  Dataset[] listDatasets(TenantId t);
  /// Removes the records, violations, profiles, match groups, jobs and
  /// snapshots too. Refused while a rule uses the dataset as reference data.
  void deleteDataset(TenantId t, DatasetId id, UserId actor);
}

interface IManageRecords {
  /// Creates and (autoValidate) validates the record.
  DataRecord createRecord(CreateRecordRequest r);
  DataRecord updateRecord(UpdateRecordRequest r);
  DataRecord getRecord(TenantId t, DatasetId ds, RecordId id);
  DataRecord[] listRecords(TenantId t, DatasetId ds);
  void deleteRecord(TenantId t, DatasetId ds, RecordId id, UserId actor);
  /// Bulk import in one storage batch; validates the dataset afterwards.
  ImportResult importRecords(ImportRecordsRequest r);
}
