/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.models;

import uim.platform.ai_launchpad.domain.ports.repositories.models;
import uim.platform.ai_launchpad.domain.entities.model : Model;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageModelsUseCase : UIMUseCase {
  private IModelRepository repo;

  this(IModelRepository repo) {
    this.repo = repo;
  }

  CommandResult register(RegisterModelRequest r) {
    if (r.name.length == 0) return CommandResult(false, "", "Model name is required");

    Model m;
    m.id = randomUUID();
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
    m.createdAt = "now";
    m.modifiedAt = "now";
    repo.save(m);
    return CommandResult(true, m.id, "");
  }

  Model getbyId(ModelId id, ConnectionId connectionId) {
    return repo.findById(id, connectionId);
  }

  Model[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  Model[] listByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    return repo.findByScenario(scenarioId, connectionId);
  }

  CommandResult patch(PatchModelRequest r) {
    auto m = repo.findById(r.modelId, r.connectionId);
    if (m.id.isEmpty) return CommandResult(false, "", "Model not found");
    if (r.description.length > 0) m.description = r.description;
    if (r.status == "archived") m.status = ModelStatus.archived;
    else if (r.status == "deprecated") m.status = ModelStatus.deprecated_;
    m.modifiedAt = "now";
    repo.save(m);
    return CommandResult(true, m.id, "");
  }

  CommandResult remove(ModelId id, ConnectionId connectionId) {
    auto m = repo.findById(id, connectionId);
    if (m.id.isEmpty) return CommandResult(false, "", "Model not found");
    repo.remove(id, connectionId);
    return CommandResult(true, id.toString, "");
  }
}
