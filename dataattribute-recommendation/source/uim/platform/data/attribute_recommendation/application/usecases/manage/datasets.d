/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.application.usecases.manage.datasets;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.data_records;
import uim.platform.data.attribute_recommendation.application.dto;

class ManageDatasetsUseCase { // TODO: UIMUseCase {
  private DatasetRepository repo;
  private DataRecordRepository recordRepo;

  this(DatasetRepository repo, DataRecordRepository recordRepo) {
    this.repo = repo;
    this.recordRepo = recordRepo;
  }

  CommandResult createDataset(CreateDatasetRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Dataset name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Dataset with this name already exists");

    auto now = Clock.currStdTime();
    auto ds = Dataset();
    ds.id = randomUUID();
    ds.tenantId = req.tenantId;
    ds.name = req.name;
    ds.description = req.description;
    ds.dataType = req.dataType;
    ds.columnDefinitions = req.columnDefinitions;
    ds.status = DatasetStatus.draft;
    ds.createdBy = req.createdBy;
    ds.createdAt = now;
    ds.updatedAt = now;

    repo.save(ds);
    return CommandResult(ds.id, "");
  }

  Dataset* getDataset(DatasetId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Dataset[] listDatasets(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateDataset(UpdateDatasetRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Dataset ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing.isNull)
      return CommandResult(false, "", "Dataset not found");

    if (existing.status != DatasetStatus.draft)
      return CommandResult(false, "", "Only draft datasets can be updated");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.columnDefinitions.length > 0)
      updated.columnDefinitions = req.columnDefinitions;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Validate a dataset and transition it to 'ready' status.
  CommandResult validateDataset(DatasetId tenantId, id tenantId) {
    auto ds = repo.findById(tenantId, id);
    if (ds.isNull)
      return CommandResult(false, "", "Dataset not found");

    if (ds.status != DatasetStatus.draft)
      return CommandResult(false, "", "Only draft datasets can be validated");

    if (ds.columnDefinitions.length == 0)
      return CommandResult(false, "", "Column definitions are required before validation");

    auto now = Clock.currStdTime();
    ds.rowCount = recordRepo.countByDataset(tenantId, id);
    ds.status = DatasetStatus.ready;
    ds.validationMessage = "Validation successful";
    ds.updatedAt = now;

    repo.update(*ds);
    return CommandResult(true, id.toString, "");
  }

  /// Process a dataset (simulate data preparation).
  CommandResult processDataset(DatasetId tenantId, id tenantId) {
    auto ds = repo.findById(tenantId, id);
    if (ds.isNull)
      return CommandResult(false, "", "Dataset not found");

    if (ds.status != DatasetStatus.ready)
      return CommandResult(false, "", "Dataset must be in 'ready' status to process");

    auto now = Clock.currStdTime();
    ds.status = DatasetStatus.completed;
    ds.updatedAt = now;

    repo.update(*ds);
    return CommandResult(true, id.toString, "");
  }

  CommandResult deleteDataset(DatasetId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Dataset not found");

    // Cascade delete records
    recordRepo.removeByDataset(tenantId, id);
    repo.removeById(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
