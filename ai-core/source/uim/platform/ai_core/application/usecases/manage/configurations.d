/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.configurations;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.configuration;
// import uim.platform.ai_core.domain.ports.repositories.configurations;



import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageConfigurationsUseCase { // TODO: UIMUseCase {
  private ConfigurationRepository repo;

  this(ConfigurationRepository repo) {
    this.repo = repo;
  }

  CommandResult createConfiguration(CreateConfigurationRequest r) {
    if (r.name.isEmpty)
      return CommandResult(false, "", "Configuration name is required");
    if (r.scenarioId.isEmpty)
      return CommandResult(false, "", "Scenario ID is required");
    if (r.executableId.isEmpty)
      return CommandResult(false, "", "Executable ID is required");
    if (r.resourceGroupId.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    auto c = Configuration(r.tenantId, r.configurationId.isNull ? ConfigurationId(createId()) : r.configurationId); // , r.createdBy);
    c.resourceGroupId = r.resourceGroupId;
    c.scenarioId = r.scenarioId;
    c.executableId = r.executableId;
    c.name = r.name;
    // c.description = r.description;
    // Parse parameter values from key-value pairs
    ParameterValue[] params;
    foreach (pair; r.parameterValues) {
      if (pair.length >= 2) {
        ParameterValue pv;
        pv.key = pair[0];
        pv.value = pair[1];
        params ~= pv;
      }
    }
    c.parameterValues = params;

    // Parse input artifact references
    InputArtifactRef[] artifacts;
    foreach (pair; r.inputArtifacts) {
      if (pair.length >= 2) {
        InputArtifactRef ar;
        ar.key = pair[0];
        ar.artifactId = pair[1];
        artifacts ~= ar;
      }
    }
    c.inputArtifacts = artifacts;

    
    c.createdAt = currentTimestamp;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  Configuration getConfiguration(TenantId tenantId, ResourceGroupId resourceGroupId, ConfigurationId configurationId) {
    return repo.findById(tenantId, resourceGroupId, configurationId);
  }

  Configuration[] listConfigurations(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId) {
    return repo.findByScenario(tenantId, resourceGroupId, scenarioId);
  }

  Configuration[] listConfigurations(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return repo.findByResourceGroup(tenantId, resourceGroupId);
  }

  CommandResult deleteConfiguration(TenantId tenantId, ResourceGroupId resourceGroupId, ConfigurationId configurationId) {
    auto config = repo.findById(tenantId, resourceGroupId, configurationId);
    if (config.isNull)
      return CommandResult(false, "", "Configuration not found");

    repo.remove(config);
    return CommandResult(true, config.id.value, "");
  }

  size_t count(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return repo.countByResourceGroup(tenantId, resourceGroupId);
  }
}
