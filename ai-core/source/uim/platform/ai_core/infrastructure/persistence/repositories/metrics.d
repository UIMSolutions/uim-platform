/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.repositories.metrics;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.metric;
// import uim.platform.ai_core.domain.ports.repositories.metrics;

import uim.platform.ai_core;
mixin(ShowModule!()); 

@safe:
class MemoryMetricRepository : TenantRepository!(Metric, MetricId), MetricRepository {
  
  bool existsById(TenantId tenantId, ResourceGroupId rgId, MetricId id) {
    return findByResourceGroup(tenantId, rgId).any!(m => m.id == id);
  }
  Metric findById(TenantId tenantId, ResourceGroupId rgId, MetricId id) {
    auto metrics = findByResourceGroup(tenantId, rgId);
    foreach (m; metrics) {
      if (m.id == id) {
        return m;
      }
    }
    return Metric.init;
  }
  void removeById(TenantId tenantId, ResourceGroupId rgId, MetricId id) {
    remove(findById(tenantId, rgId, id));
  }

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Metric[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(m => remove(m));
  }

  // #region ByExecution
  size_t countByExecution(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    return findByExecution(tenantId, rgId, execId).length;
  } 
  Metric[] filterByExecution(Metric[] metrics, ExecutionId execId) {
    return metrics.filter!(m => m.executionId == execId).array;
  }
  Metric[] findByExecution(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    return filterByExecution(findByResourceGroup(tenantId, rgId), execId);
  }
  void removeByExecution(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    findByExecution(tenantId, rgId, execId).each!(m => remove(m));
  }
  // #endregion ByExecution

}
