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

  MetricDefinition[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  MetricDefinition[] findByCategory(TenantId tenantId, MetricCategory category) {
    return findByTenant(tenantId).filter!(e => e.category == category).array;
  }

}
