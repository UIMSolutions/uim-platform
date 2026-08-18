/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.usecases.manage.datasets;




import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class ManageDatasetsUseCase {
  protected IDatasetRepository repo;
  private IDataRecordRepository recordRepo;

  this(IDatasetRepository repo, IDataRecordRepository recordRepo) {
    this.repo = repo;
    this.recordRepo = recordRepo;
  }

  UsecaseResult createDataset(CreateDatasetRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Dataset name is required");

    if (repo.existsByName(req.tenantId, req.name))
        return UsecaseResult(false, "", "Dataset with this name already exists");

    auto ds = Dataset(req.tenantId, DatasetId(createId), req.createdBy);

    ds.name = req.name;
    ds.description = req.description;
    ds.dataType = req.dataType.toDataType;
    ds.columnDefinitions = req.columnDefinitions;
    ds.status = DatasetStatus.draft;

    repo.save(ds);
    return UsecaseResult(true, ds.id.value, "");
  }

  Dataset getDataset(TenantId tenantId, DatasetId id) {
    return repo.findById(tenantId, id);
  }

  Dataset[] listDatasets(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateDataset(UpdateDatasetRequest req) {
    if (req.datasetId.isNull)
      return UsecaseResult(false, "", "Dataset ID is required");

    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.datasetId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Dataset not found");

    if (existing.status != DatasetStatus.draft)
      return UsecaseResult(false, "", "Only draft datasets can be updated");

    auto updated = existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.columnDefinitions.length > 0)
      updated.columnDefinitions = req.columnDefinitions;
    updated.updatedAt = currentTimestamp();

    repo.update(updated);
    return UsecaseResult(true, updated.id.value, "");
  }

  /// Validate a dataset and transition it to 'ready' status.
  UsecaseResult validateDataset(TenantId tenantId, DatasetId id) {
    auto ds = repo.findById(tenantId, id);
    if (ds.isNull)
      return UsecaseResult(false, "", "Dataset not found");

    if (ds.status != DatasetStatus.draft)
      return UsecaseResult(false, "", "Only draft datasets can be validated");

    if (ds.columnDefinitions.length == 0)
      return UsecaseResult(false, "", "Column definitions are required before validation");

    auto now = currentTimestamp();
    ds.rowCount = recordRepo.countByDataset(tenantId, id);
    ds.status = DatasetStatus.ready;
    ds.validationMessage = "Validation successful";
    ds.updatedAt = now;

    repo.update(ds);
    return UsecaseResult(true, id.value, "");
  }

  /// Process a dataset (simulate data preparation).
  UsecaseResult processDataset(TenantId tenantId, DatasetId id) {
    auto ds = repo.findById(tenantId, id);
    if (ds.isNull)
      return UsecaseResult(false, "", "Dataset not found");

    if (ds.status != DatasetStatus.ready)
      return UsecaseResult(false, "", "Dataset must be in 'ready' status to process");

    auto now = currentTimestamp();
    ds.status = DatasetStatus.completed;
    ds.updatedAt = now;

    repo.update(ds);
    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult deleteDataset(TenantId tenantId, DatasetId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Dataset not found");

    // Cascade delete records
    recordRepo.removeByDataset(tenantId, id);

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
    auto iDatasetRepository = new IDatasetRepository();
    auto iDataRecordRepository = new IDataRecordRepository();
    auto usecase = new ManageDatasetsUseCase(iDatasetRepository, iDataRecordRepository);
    auto tenantId = TenantId("test-tenant");

    // Test list
    auto items = usecase.listDatasets(tenantId);
    assert(items !is null);

}
