/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.scenarios;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface IManageScenariosUseCase { 

  UsecaseResult createScenario(CreateScenarioRequest r);
  Scenario getScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId id);
  Scenario[] listScenarios(TenantId tenantId, ResourceGroupId rgId);
  UsecaseResult deleteScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId id);
  size_t countScenarios(TenantId tenantId, ResourceGroupId rgId);

}
