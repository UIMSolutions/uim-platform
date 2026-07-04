/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.datasets;
// import uim.platform.analytics.domain.entities.dataset;
// import uim.platform.analytics.domain.repositories.dataset;

// import uim.platform.analytics.app.dto.dataset;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class DatasetUseCases {
  private DatasetRepository repo;

  this(DatasetRepository repo) {
    this.repo = repo;
  }

  DatasetResponse createDataset(CreateDatasetRequest req) {
    auto ds = Dataset.create(req.name, req.description, req.dataSourceId, req.userId);
    repo.save(ds);
    return DatasetResponse.fromEntity(ds);
  }

  DatasetResponse getDataset(TenantId tenantId, DatasetId id) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id == id).array;
    return DatasetResponse.fromEntity(found.empty ? Dataset.init : found[0]);
  }

  DatasetResponse[] listDatasets(TenantId tenantId) {
    DatasetResponse[] result;
    foreach (d; repo.findByTenant(tenantId))
      result ~= DatasetResponse.fromEntity(d);
    return result;
  }

  CommandResult deleteDataset(TenantId tenantId, DatasetId datasetId) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id == datasetId).array;
    if (found.empty)
      return CommandResult(false, "", "Dataset not found");
    auto ds = found[0];
    repo.remove(ds);
    return CommandResult(true, ds.id.value, "");
  }
}
