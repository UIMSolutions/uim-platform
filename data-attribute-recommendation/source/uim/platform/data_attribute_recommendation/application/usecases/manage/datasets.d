module application.usecases.manage_datasets;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation.domain.entities.dataset;
import uim.platform.data_attribute_recommendation.domain.ports.dataset_repository;
import uim.platform.data_attribute_recommendation.domain.ports.data_record_repository;
import uim.platform.data_attribute_recommendation.application.dto;

class ManageDatasetsUseCase
{
  private DatasetRepository repo;
  private DataRecordRepository recordRepo;

  this(DatasetRepository repo, DataRecordRepository recordRepo)
  {
    this.repo = repo;
    this.recordRepo = recordRepo;
  }

  CommandResult createDataset(CreateDatasetRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Dataset name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Dataset with this name already exists");

    auto now = Clock.currStdTime();
    auto ds = Dataset();
    ds.id = randomUUID().toString();
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

  Dataset* getDataset(DatasetId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Dataset[] listDatasets(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateDataset(UpdateDatasetRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Dataset ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Dataset not found");

    if (existing.status != DatasetStatus.draft)
      return CommandResult("", "Only draft datasets can be updated");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    if (req.description.length > 0) updated.description = req.description;
    if (req.columnDefinitions.length > 0) updated.columnDefinitions = req.columnDefinitions;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Validate a dataset and transition it to 'ready' status.
  CommandResult validateDataset(DatasetId id, TenantId tenantId)
  {
    auto ds = repo.findById(id, tenantId);
    if (ds is null)
      return CommandResult("", "Dataset not found");

    if (ds.status != DatasetStatus.draft)
      return CommandResult("", "Only draft datasets can be validated");

    if (ds.columnDefinitions.length == 0)
      return CommandResult("", "Column definitions are required before validation");

    auto now = Clock.currStdTime();
    ds.rowCount = recordRepo.countByDataset(id, tenantId);
    ds.status = DatasetStatus.ready;
    ds.validationMessage = "Validation successful";
    ds.updatedAt = now;

    repo.update(*ds);
    return CommandResult(id, "");
  }

  /// Process a dataset (simulate data preparation).
  CommandResult processDataset(DatasetId id, TenantId tenantId)
  {
    auto ds = repo.findById(id, tenantId);
    if (ds is null)
      return CommandResult("", "Dataset not found");

    if (ds.status != DatasetStatus.ready)
      return CommandResult("", "Dataset must be in 'ready' status to process");

    auto now = Clock.currStdTime();
    ds.status = DatasetStatus.completed;
    ds.updatedAt = now;

    repo.update(*ds);
    return CommandResult(id, "");
  }

  CommandResult deleteDataset(DatasetId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Dataset not found");

    // Cascade delete records
    recordRepo.removeByDataset(id, tenantId);
    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
