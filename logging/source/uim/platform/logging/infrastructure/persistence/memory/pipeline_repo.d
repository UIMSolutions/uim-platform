/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.pipeline;

import uim.platform.logging.domain.entities.pipeline;
import uim.platform.logging.domain.ports.repositories.pipelines;
import uim.platform.logging.domain.types;

class MemoryPipelineRepository : PipelineRepository {
  private Pipeline[PipelineId] store;

  Pipeline findById(PipelineId id) {
    if (auto p = id in store)
      return *p;
    return Pipeline.init;
  }

  Pipeline[] findByTenant(TenantId tenantId) {
    Pipeline[] result;
    foreach (ref p; store)
      if (p.tenantId == tenantId)
        result ~= p;
    return result;
  }

  Pipeline[] findActive(TenantId tenantId) {
    Pipeline[] result;
    foreach (ref p; store)
      if (p.tenantId == tenantId && p.isActive)
        result ~= p;
    return result;
  }

  Pipeline[] findBySource(TenantId tenantId, PipelineSourceType sourceType) {
    Pipeline[] result;
    foreach (ref p; store)
      if (p.tenantId == tenantId && p.sourceType == sourceType)
        result ~= p;
    return result;
  }

  void save(Pipeline p) {
    store[p.id] = p;
  }

  void update(Pipeline p) {
    store[p.id] = p;
  }

  void remove(PipelineId id) {
    store.remove(id);
  }
}
