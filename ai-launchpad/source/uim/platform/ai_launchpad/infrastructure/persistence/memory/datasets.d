/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.datasets;
// import uim.platform.ai_launchpad.domain.ports.repositories.datasets;
// import uim.platform.ai_launchpad.domain.entities.dataset : Dataset;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryDatasetRepository : TenantRepository!(Dataset, DatasetId), IDatasetRepository {
  
  bool existsById(TenantId tenantId, ConnectionId connectionId, DatasetId id) {
    return findByConnection(tenantId, connectionId).any!(d => d.id == id);
  }
  Dataset findById(TenantId tenantId, ConnectionId connectionId, DatasetId id) {
    foreach(d; findByConnection(tenantId, connectionId)) {
      if (d.id == id) return d;
    }
    return Dataset.init;
  }
  void removeById(TenantId tenantId, ConnectionId connectionId, DatasetId id) {
    remove(findById(tenantId, connectionId, id));
  }
  
  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }
  Dataset[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }
  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    foreach(d; findByConnection(tenantId, connectionId)) {
      remove(d);
    }
  }

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return findByScenario(tenantId, connectionId, scenarioId).length;
  }
  Dataset[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return filterByScenario(findByConnection(tenantId, connectionId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    foreach(d; findByScenario(tenantId, connectionId, scenarioId)) {
      remove(d);
    }
  }

}
