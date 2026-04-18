/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.pipelines;

// import uim.platform.logging.domain.entities.pipeline;
// import uim.platform.logging.domain.ports.repositories.pipelines;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryPipelineRepository : PipelineRepository {
  private Pipeline[PipelineId] store;

  bool existsById(PipelineId id) {
    return (id in store) ? true : false;
  }

  Pipeline findById(PipelineId id) {
    return (existsById(id)) ? store[id] : Pipeline.init;
  }

  Pipeline[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(p => p.tenantId == tenantId).array;
  }

  Pipeline[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(p => p.isActive).array;
  }

  Pipeline[] findBySource(TenantId tenantId, PipelineSourceType sourceType) {
    return findByTenant(tenantId).filter!(p => p.sourceType == sourceType).array;
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
