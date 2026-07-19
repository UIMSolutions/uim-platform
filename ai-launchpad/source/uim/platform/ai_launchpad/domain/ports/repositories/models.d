/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.models;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.model : Model;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IModelRepository : ITenantRepository!(Model, ModelId) {

  bool existsById(TenantId tenantId, ConnectionId connectionId, ModelId id);
  Model findById(TenantId tenantId, ConnectionId connectionId, ModelId id);
  void removeById(TenantId tenantId, ConnectionId connectionId, ModelId id);

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId);  
  Model[] findByConnection(TenantId tenantId, ConnectionId connectionId);
  void removeByConnection(TenantId tenantId, ConnectionId connectionId);

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);
  Model[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

}
