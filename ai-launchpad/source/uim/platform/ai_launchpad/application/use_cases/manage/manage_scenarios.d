/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.scenarios;

import uim.platform.ai_launchpad.domain.ports.repositories.scenarios;
import uim.platform.ai_launchpad.domain.entities.scenario : Scenario;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

class ManageScenariosUseCase : UIMUseCase {
  private IScenarioRepository repo;

  this(IScenarioRepository repo) {
    this.repo = repo;
  }

  CommandResult sync(SyncScenarioRequest r) {
    Scenario s;
    s.id = r.scenarioId;
    s.connectionId = r.connectionId;
    s.name = r.name;
    s.description = r.description;
    s.labels = r.labels;
    s.createdAt = "now";
    s.modifiedAt = "now";
    repo.save(s);
    return CommandResult(true, s.id, "");
  }

  Scenario get_(ScenarioId id, ConnectionId connectionId) {
    return repo.findById(id, connectionId);
  }

  Scenario[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  Scenario[] listAll() {
    return repo.findAll();
  }

  CommandResult remove(ScenarioId id, ConnectionId connectionId) {
    auto s = repo.findById(id, connectionId);
    if (s.id.isEmpty) return CommandResult(false, "", "Scenario not found");
    repo.remove(id, connectionId);
    return CommandResult(true, id, "");
  }
}
