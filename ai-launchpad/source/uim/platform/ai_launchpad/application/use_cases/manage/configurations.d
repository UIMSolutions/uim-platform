/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.use_cases.manage.configurations;

// import uim.platform.ai_launchpad.domain.ports.repositories.configurations;
// import uim.platform.ai_launchpad.domain.entities.configuration;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

// import std.uuid : randomUUID;
// import std.conv : to;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ManageConfigurationsUseCase { // TODO: UIMUseCase {
  private IConfigurationRepository repo;

  this(IConfigurationRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateConfigurationRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Configuration name is required");

    Configuration c;
    c.id = randomUUID();
    c.connectionId = r.connectionId;
    c.scenarioId = r.scenarioId;
    c.executableId = r.executableId;
    c.name = r.name;

    foreach (pv; r.parameterValues) {
      if (pv.length >= 2) {
        c.parameters ~= ParameterBinding(pv[0], pv[1]);
      }
    }
    foreach (ia; r.inputArtifacts) {
      if (ia.length >= 2) {
        c.inputArtifacts ~= InputArtifactBinding(ia[0], ia[1]);
      }
    }

    c.createdAt = "now";
    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  Configuration getById(ConfigurationId id, ConnectionId connectionId) {
    return repo.findById(id, connectionId);
  }

  Configuration[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  Configuration[] listByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    return repo.findByScenario(scenarioId, connectionId);
  }

  CommandResult remove(ConfigurationId id, ConnectionId connectionId) {
    if (!repo.existsById(id, connectionId))
      return CommandResult(false, "", "Configuration not found");

    repo.remove(id, connectionId);
    return CommandResult(true, id.value, "");
  }
}
