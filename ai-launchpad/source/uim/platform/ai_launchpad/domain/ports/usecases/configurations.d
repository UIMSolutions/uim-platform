/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.configurations;
// import uim.platform.ai_launchpad.domain.ports.repositories.configurations;
// import uim.platform.ai_launchpad.domain.entities.configuration;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IManageConfigurationsUseCase { 
  
  CommandResult createConfiguration(CreateConfigurationRequest r);

  Configuration getConfiguration(TenantId tenantId, ConnectionId connectionId, ConfigurationId id);

  Configuration[] listConfigurations(TenantId tenantId, ConnectionId connectionId);

  Configuration[] listConfigurations(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  CommandResult deleteConfiguration(TenantId tenantId, ConnectionId connectionId, ConfigurationId id);
  
}
