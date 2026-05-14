/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.models;

// import uim.platform.ai_launchpad.domain.ports.modelssitories.models;
// import uim.platform.ai_launchpad.domain.entities.model : Model;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

// import std.uuid : randomUUID;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageModelsUseCase { // TODO: UIMUseCase {
  private IModelmodelssitory models;

  this(IModelmodelssitory models) {
    this.models = models;
  }

  CommandResult register(RegisterModelRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Model name is required");

    Model m;
    m.initEntity(r.tenantId);

    m.connectionId = r.connectionId;
    m.name = r.name;
    m.version_ = r.version_;
    m.description = r.description;
    m.scenarioId = r.scenarioId;
    m.executionId = r.executionId;
    m.url = r.url;
    m.size = r.size;
    m.status = ModelStatus.available;
    m.labels = r.labels;

    models.save(m);
    return CommandResult(true, m.id.value, "");
  }

  Model getById(TenantId tenantId, ConnectionId connectionId, ModelId id) {
    return models.findById(tenantId, connectionId, id);
  }

  Model[] listByConnection(TenantId tenantId, ConnectionId connectionId) {
    return models.findByConnection(tenantId, connectionId);
  }

  Model[] listByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return models.findByScenario(tenantId, connectionId, scenarioId);
  }

  CommandResult patch(PatchModelRequest r) {
    auto m = models.findById(r.tenantId, r.connectionId, r.modelId);

    if (m.isNull)
      return CommandResult(false, "", "Model not found");
    if (r.description.length > 0)
      m.description = r.description;
    if (r.status == "archived")
      m.status = ModelStatus.archived;
    else if (r.status == "deprecated")
      m.status = ModelStatus.deprecated_;
    m.updatedAt = Clock.currStdTime();

    models.save(m);
    return CommandResult(true, m.id.value, "");
  }

  CommandResult deleteModel(TenantId tenantId, ConnectionId connectionId, ModelId id) {
    auto model = models.findById(tenantId, connectionId, id);
    if (model.isNull)
      return CommandResult(false, "", "Model not found");

    models.remove(model);
    return CommandResult(true, model.id.value, "");
  }
}
