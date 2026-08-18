/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usecases.anonymization_configs;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageAnonymizationConfigsUseCase { 

  UsecaseResult createConfig(CreateAnonymizationConfigRequest req);
  AnonymizationConfig getConfig(TenantId tenantId, AnonymizationConfigId id);
  AnonymizationConfig[] listConfigs(TenantId tenantId);
  UsecaseResult updateConfig(UpdateAnonymizationConfigRequest req);
  UsecaseResult activateConfig(TenantId tenantId, AnonymizationConfigId configId);
  UsecaseResult deleteConfig(TenantId tenantId, AnonymizationConfigId configId);
  
}
