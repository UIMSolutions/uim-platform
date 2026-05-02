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

  CommandResult createRecord(CreateDataRecordRequest req) {
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

    auto record = DataRecord();
    record.id = randomUUID();
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

  DataRecord* getRecord(DataRecordId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  DataRecord[] listByDataset(DatasetId datasettenantId, id tenantId) {
    return repo.findByDataset(datasettenantId, id);
  }

  CommandResult validateRecord(DataRecordId tenantId, id tenantId) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return CommandResult(false, "", "Record not found");

    record.status = RecordStatus.validated;
    repo.update(*record);
    return CommandResult(true, id.value, "");
  }

  CommandResult rejectRecord(DataRecordId tenantId, id tenantId) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return CommandResult(false, "", "Record not found");

    record.status = RecordStatus.rejected;
    repo.update(*record);
    return CommandResult(true, id.value, "");
  }

  CommandResult deleteRecord(DataRecordId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Record not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
