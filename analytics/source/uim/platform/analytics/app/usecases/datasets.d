/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.datasets;

// import uim.platform.analytics.domain.entities.dataset;
// import uim.platform.analytics.domain.repositories.dataset;
// import uim.platform.analytics.domain.values.common;
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

  DatasetResponse getDataset(string id) {
    return DatasetResponse.fromEntity(repo.findById(EntityId(id)));
  }

  DatasetResponse[] listDatasets() {
    DatasetResponse[] result;
    foreach (d; repo.findAll())
      result ~= DatasetResponse.fromEntity(d);
    return result;
  }

  CommandResult deleteDataset(string datasetId) {
    auto ds = repo.findById(EntityId(datasetId));
    if (ds.isNull)
      return CommandResult(false, "", "Dataset not found");

    repo.remove(ds);
    return CommandResult(true, ds.id.value, "");
  }
}
