/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.metric_definitions;

import uim.platform.monitoring.domain.entities.metric_definition;
import uim.platform.monitoring.domain.types;

/// Port: outgoing - metric definition persistence.
interface MetricDefinitionRepository {
  MetricDefinition findById(MetricDefinitionId id);
  MetricDefinition[] findByTenant(TenantId tenantId);
  MetricDefinition[] findByCategory(TenantId tenantId, MetricCategory category);
  MetricDefinition findByName(TenantId tenantId, string name);
  void save(MetricDefinition def);
  void update(MetricDefinition def);
  void remove(MetricDefinitionId id);
}
