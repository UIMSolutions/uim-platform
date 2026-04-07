/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.metric_definition_repo;

import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.domain.entities.metric_definition;
import uim.platform.monitoring.domain.ports.repositories.metric_definitions;

// import std.algorithm : filter;
// import std.array : array;

class MemoryMetricDefinitionRepository : MetricDefinitionRepository {
  private MetricDefinition[MetricDefinitionId] store;

  MetricDefinition findById(MetricDefinitionId id) {
    if (auto p = id in store)
      return *p;
    return MetricDefinition.init;
  }

  MetricDefinition[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  MetricDefinition[] findByCategory(TenantId tenantId, MetricCategory category) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.category == category).array;
  }

  MetricDefinition findByName(TenantId tenantId, string name) {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return MetricDefinition.init;
  }

  void save(MetricDefinition def) {
    store[def.id] = def;
  }

  void update(MetricDefinition def) {
    store[def.id] = def;
  }

  void remove(MetricDefinitionId id) {
    store.remove(id);
  }
}
