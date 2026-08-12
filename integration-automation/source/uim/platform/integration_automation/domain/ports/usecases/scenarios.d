/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.application.usecases.manage.scenarios;



// import uim.platform.integration_automation.domain.entities.integration_scenario;
// import uim.platform.integration_automation.domain.ports.repositories.scenarios;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
interface IManageScenariosUseCase { 

  CommandResult createScenario(CreateScenarioRequest req);

  IntegrationScenario getScenario(TenantId tenantId, ScenarioId id);

  IntegrationScenario[] listScenarios(TenantId tenantId);

  IntegrationScenario[] listByCategory(TenantId tenantId, ScenarioCategory category);

  IntegrationScenario[] listActive(TenantId tenantId);

  CommandResult updateScenario(UpdateScenarioRequest req);

  CommandResult deleteScenario(TenantId tenantId, ScenarioId id);
  
}
