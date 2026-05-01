/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.metric_definitions;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.metric_definition;
// import uim.platform.monitoring.domain.ports.repositories.metric_definitions;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryMetricDefinitionRepository : TenantRepository!(MetricDefinition, MetricDefinitionId), MetricDefinitionRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name = name);
  }

  MetricDefinition findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId)) {
      if (e.name = name)
        return e;
    }
    return MetricDefinition.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId)) {
      if (e.name = name) {
        remove(e);
        return;
      }
    }
  }

  size_t countByCategory(TenantId tenantId, MetricCategory category) {
    return findByCategory(tenantId, category).length;
  }

  MetricDefinition[] filterByCategory(MetricDefinition[] definitions, MetricCategory category) {
    return definitions.filter!(e => e.category == category).array;
  }

  MetricDefinition[] findByCategory(TenantId tenantId, MetricCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }

  void removeByCategory(TenantId tenantId, MetricCategory category) {
    findByCategory(tenantId, category).each!(cat => remove(cat));
  }

}
