/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.configurations;
// import uim.platform.ai_launchpad.domain.ports.repositories.configurations;
// import uim.platform.ai_launchpad.domain.entities.configuration;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

class ManageConfigurationsUseCase { // TODO: UIMUseCase {
  private IConfigurationRepository repo;

  this(IConfigurationRepository repo) {
    this.repo = repo;
  }

  CommandResult createConfiguration(CreateConfigurationRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Configuration name is required");

    auto c = Configuration(r.tenantId, r.configurationId.isNull ? ConfigurationId(createId()) : r.configurationId); // , r.createdBy);
    c.connectionId = r.connectionId;
    c.scenarioId = r.scenarioId;
    // c.executableId = r.executableId;
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

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  Configuration getConfiguration(TenantId tenantId, ConnectionId connectionId, ConfigurationId id) {
    return repo.findById(tenantId, connectionId, id);
  }

  Configuration[] listConfigurations(TenantId tenantId, ConnectionId connectionId) {
    return repo.findByConnection(tenantId, connectionId);
  }

  Configuration[] listConfigurations(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return repo.findByScenario(tenantId, connectionId, scenarioId);
  }

  CommandResult deleteConfiguration(TenantId tenantId, ConnectionId connectionId, ConfigurationId id) {
    auto config = repo.findById(tenantId, connectionId, id);
    if (config.isNull)
      return CommandResult(false, "", "Configuration not found");

    repo.remove(config);
    return CommandResult(true, config.id.value, "");
  }
}
