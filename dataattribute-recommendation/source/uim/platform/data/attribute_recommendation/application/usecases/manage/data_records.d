/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.application.usecases.manage.data_records;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.data_record;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.data_records;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;
import uim.platform.data.attribute_recommendation.application.dto;

class ManageDataRecordsUseCase { // TODO: UIMUseCase {
  private DataRecordRepository repo;
  private DatasetRepository datasetRepo;

  this(DataRecordRepository repo, DatasetRepository datasetRepo) {
    this.repo = repo;
    this.datasetRepo = datasetRepo;
  }

  CommandResult createDataRecord(CreateDataRecordRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.datasetId.isEmpty)
      return CommandResult(false, "", "Dataset ID is required");
    if (req.attributes.length == 0)
      return CommandResult(false, "", "Attributes are required");

    // Verify dataset exists and is still mutable
    auto ds = datasetRepo.findById(req.datasetId, req.tenantId);
    if (ds.isNull)
      return CommandResult(false, "", "Dataset not found");
    if (ds.status != DatasetStatus.draft && ds.status != DatasetStatus.ready)
      return CommandResult(false, "", "Cannot add records to a processed or completed dataset");

    DataRecord record;
    record.initEntity(req.tenantId, req.createdBy);

    record.datasetId = req.datasetId;
    record.tenantId = req.tenantId;
    record.attributes = req.attributes;
    record.labels = req.labels;
    record.status = RecordStatus.pending;

    repo.save(record);
    return CommandResult(true, record.id.value, "");
  }

  DataRecord getDataRecord(TenantId tenantId, DataRecordId id) {
    return repo.findById(tenantId, id);
  }

  DataRecord[] listDataRecords(TenantId tenantId, DatasetId datasetId) {
    return repo.findByDataset(datasetId, tenantId);
  }

  CommandResult validateDataRecord(TenantId tenantId, DataRecordId id) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return CommandResult(false, "", "Record not found");

    record.status = RecordStatus.validated;
    repo.update(record);
    return CommandResult(true, record.id.value, "");
  }

  CommandResult rejectDataRecord(TenantId tenantId, DataRecordId id) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return CommandResult(false, "", "Record not found");

    record.status = RecordStatus.rejected;
    repo.update(record);
    return CommandResult(true, record.id.value, "");
  }

  CommandResult deleteDataRecord(TenantId tenantId, DataRecordId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Record not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }
}
