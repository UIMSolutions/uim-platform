/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.repositories.models;

// import uim.platform.ai_launchpad.domain.ports.repositories.models;
// import uim.platform.ai_launchpad.domain.entities.model : Model;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:
class MemoryModelRepository : TenantRepository!(Model, ModelId), IModelRepository {
  
    bool existsById(TenantId tenantId, ConnectionId connectionId, ModelId id) {
    return findByConnection(tenantId, connectionId).any!(m => m.id == id);
  }

  Model findById(TenantId tenantId, ConnectionId connectionId, ModelId id) {
    foreach (m; findByConnection(tenantId, connectionId)) {
      if (m.id == id) return m;
    }
    return Model.init;
  }
  void removeById(TenantId tenantId, ConnectionId connectionId, ModelId id) {
    auto model = findById(tenantId, connectionId, id);
    remove(model);
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }
  Model[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }
  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    findByConnection(tenantId, connectionId).each!(m => remove(m));
  }

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return findByScenario(tenantId, connectionId, scenarioId).length;
  }
  Model[] filterByScenario(Model[] models, ScenarioId scenarioId) {
    return models.filter!(m => m.scenarioId == scenarioId).array;
  } 
  Model[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return filterByScenario(findByConnection(tenantId, connectionId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    findByScenario(tenantId, connectionId, scenarioId).each!(m => remove(m));
  }


}
