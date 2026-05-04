/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.use_cases.manage.datasets;

// import uim.platform.ai_launchpad.domain.ports.repositories.datasets;
// import uim.platform.ai_launchpad.domain.entities.dataset : Dataset;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

// import std.uuid : randomUUID;
// import std.conv : to;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageDatasetsUseCase { // TODO: UIMUseCase {
  private IDatasetRepository repo;

  this(IDatasetRepository repo) {
    this.repo = repo;
  }

  CommandResult register(RegisterDatasetRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Dataset name is required");

    Dataset d;
    d.id = randomUUID();
    d.connectionId = r.connectionId;
    d.name = r.name;
    d.description = r.description;
    d.scenarioId = r.scenarioId;
    d.url = r.url;
    d.size = r.size;
    d.status = DatasetStatus.available;
    d.labels = r.labels;
    d.createdAt = "now";
    d.updatedAt = "now";
    repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  Dataset getById(ConnectionId connectionId, DatasetId id) {
    return repo.findById(connectionId, id);
  }

  Dataset[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  Dataset[] listByScenario(ConnectionId connectionId, ScenarioId scenarioId) {
    return repo.findByScenario(connectionId, scenarioId);
  }

  CommandResult patch(PatchDatasetRequest r) {
    auto d = repo.findById(r.connectionId, r.datasetId);
    if (d.isNull)
      return CommandResult(false, "", "Dataset not found");
    if (r.description.length > 0)
      d.description = r.description;
    if (r.status == "archived")
      d.status = DatasetStatus.archived;
    d.updatedAt = "now";
    repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  CommandResult remove(ConnectionId connectionId, DatasetId id) {
    auto d = repo.findById(connectionId, id);
    if (d.isNull)
      return CommandResult(false, "", "Dataset not found");
      
    repo.remove(connectionId, id);
    return CommandResult(true, id.value, "");
  }
}
