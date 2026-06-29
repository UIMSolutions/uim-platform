/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.datasets;
// import uim.platform.ai_launchpad.domain.ports.repositories.datasets;
// import uim.platform.ai_launchpad.domain.entities.dataset : Dataset;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;


import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:
class ManageDatasetsUseCase { // TODO: UIMUseCase {
  private IDatasetRepository repo;

  this(IDatasetRepository repo) {
    this.repo = repo;
  }

  CommandResult registerDataset(RegisterDatasetRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Dataset name is required");

    Dataset d;
    d.initEntity(r.tenantId);

    d.connectionId = r.connectionId;
    d.name = r.name;
    d.description = r.description;
    d.scenarioId = r.scenarioId;
    d.url = r.url;
    d.size = r.size;
    d.status = DatasetStatus.available;
    d.labels = r.labels;

    repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  Dataset getDataset(TenantId tenantId, ConnectionId connectionId, DatasetId id) {
    return repo.findById(tenantId, connectionId, id);
  }

  Dataset[] listDatasets(TenantId tenantId, ConnectionId connectionId) {
    return repo.findByConnection(tenantId, connectionId);
  }

  Dataset[] listDatasets(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return repo.findByScenario(tenantId, connectionId, scenarioId);
  }

  CommandResult patchDataset(PatchDatasetRequest r) {
    auto d = repo.findById(r.tenantId, r.connectionId, r.datasetId);
    if (d.isNull)
      return CommandResult(false, "", "Dataset not found");
    if (r.description.length > 0)
      d.description = r.description;
    if (r.status == "archived")
      d.status = DatasetStatus.archived;
    d.updatedAt = currentTimestamp;

    repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  CommandResult deleteDataset(TenantId tenantId, ConnectionId connectionId, DatasetId id) {
    auto dataset = repo.findById(tenantId, connectionId, id);
    if (dataset.isNull)
      return CommandResult(false, "", "Dataset not found");
      
    repo.remove(dataset);
    return CommandResult(true, dataset.id.value, "");
  }
}
