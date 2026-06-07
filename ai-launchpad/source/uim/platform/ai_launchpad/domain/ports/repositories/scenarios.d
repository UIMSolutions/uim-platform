/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.scenarios;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.scenario : Scenario;
import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

interface IScenarioRepository : ITenantRepository!(Scenario, ScenarioId) {

  bool existsById(TenantId tenantId, ConnectionId connectionId, ScenarioId id);
  Scenario findById(TenantId tenantId, ConnectionId connectionId, ScenarioId id);
  void removeById(TenantId tenantId, ConnectionId connectionId, ScenarioId id);

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId);
  Scenario[] findByConnection(TenantId tenantId, ConnectionId connectionId);
  void removeByConnection(TenantId tenantId, ConnectionId connectionId);

}
