/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.repositories.scenarios;

// import uim.platform.ai_launchpad.domain.ports.repositories.scenarios;
// import uim.platform.ai_launchpad.domain.entities.scenario : Scenario;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryScenarioRepository : TenantRepository!(Scenario, ScenarioId), IScenarioRepository {
  
  bool existsById(TenantId tenantId, ConnectionId connectionId, ScenarioId id) {
    return findByConnection(tenantId, connectionId).any!(s => s.id == id);
  }
  Scenario findById(TenantId tenantId, ConnectionId connectionId, ScenarioId id) {
    foreach (s; findByConnection(tenantId, connectionId)) {
      if (s.id == id)
        return s;
    }
    return Scenario.init;
  }
  void removeById(TenantId tenantId, ConnectionId connectionId, ScenarioId id) {
    auto s = findById(tenantId, connectionId, id);
    remove(s);
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }
  Scenario[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }
  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    findByConnection(tenantId, connectionId).each!(s => remove(s));
  }

}
