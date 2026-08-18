/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.configurations;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface ManageConfigurationsUseCase { 

  UsecaseResult createConfiguration(CreateConfigurationRequest r);
  Configuration getConfiguration(TenantId tenantId, ResourceGroupId resourceGroupId, ConfigurationId configurationId);
  Configuration[] listConfigurations(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId);
  Configuration[] listConfigurations(TenantId tenantId, ResourceGroupId resourceGroupId);
  UsecaseResult deleteConfiguration(TenantId tenantId, ResourceGroupId resourceGroupId, ConfigurationId configurationId);

}
