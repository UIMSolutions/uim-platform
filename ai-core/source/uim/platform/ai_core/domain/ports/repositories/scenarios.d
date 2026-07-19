/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.scenarios;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.scenario;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface ScenarioRepository : ITenantRepository!(Scenario, ScenarioId) {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ScenarioId id);
  Scenario findById(TenantId tenantId, ResourceGroupId rgId, ScenarioId id);
  void removeById(TenantId tenantId, ResourceGroupId rgId, ScenarioId id);

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  Scenario[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId);

}
