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

class ManageDataRecordsUseCase : UIMUseCase {
  private DataRecordRepository repo;
  private DatasetRepository datasetRepo;

  this(DataRecordRepository repo, DatasetRepository datasetRepo) {
    this.repo = repo;
    this.datasetRepo = datasetRepo;
  }

  CommandResult createRecord(CreateDataRecordRequest req) {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.datasetId.length == 0)
      return CommandResult("", "Dataset ID is required");
    if (req.attributes.length == 0)
      return CommandResult("", "Attributes are required");

    // Verify dataset exists and is still mutable
    auto ds = datasetRepo.findById(req.datasetId, req.tenantId);
    if (ds is null)
      return CommandResult("", "Dataset not found");
    if (ds.status != DatasetStatus.draft && ds.status != DatasetStatus.ready)
      return CommandResult("", "Cannot add records to a processed or completed dataset");

    auto record = DataRecord();
    record.id = randomUUID().toString();
    record.datasetId = req.datasetId;
    record.tenantId = req.tenantId;
    record.attributes = req.attributes;
    record.labels = req.labels;
    record.status = RecordStatus.pending;
    record.createdBy = req.createdBy;
    record.createdAt = Clock.currStdTime();

    repo.save(record);
    return CommandResult(record.id, "");
  }

  DataRecord* getRecord(DataRecordId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  DataRecord[] listByDataset(DatasetId datasetId, TenantId tenantId) {
    return repo.findByDataset(datasetId, tenantId);
  }

  CommandResult validateRecord(DataRecordId id, TenantId tenantId) {
    auto record = repo.findById(id, tenantId);
    if (record is null)
      return CommandResult("", "Record not found");

    record.status = RecordStatus.validated;
    repo.update(*record);
    return CommandResult(id, "");
  }

  CommandResult rejectRecord(DataRecordId id, TenantId tenantId) {
    auto record = repo.findById(id, tenantId);
    if (record is null)
      return CommandResult("", "Record not found");

    record.status = RecordStatus.rejected;
    repo.update(*record);
    return CommandResult(id, "");
  }

  CommandResult deleteRecord(DataRecordId id, TenantId tenantId) {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Record not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
