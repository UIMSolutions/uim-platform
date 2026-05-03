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
class MemoryPipelineRepository : TenantRepository!(Pipeline, PipelineId), PipelineRepository {
  
  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }
  Pipeline[] filterActive(Pipeline[] pipelines) {
    return pipelines.filter!(p => p.isActive).array;
  }
  Pipeline[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(p => p.isActive).array;
  }
  void removeByActive(TenantId tenantId) {
    findActive(tenantId).each!(p => remove(p));
  }

  size_t countBySource(TenantId tenantId, PipelineSourceType sourceType) {
    return findBySource(tenantId, sourceType).length;
  }
  Pipeline[] filterBySource(Pipeline[] pipelines, PipelineSourceType sourceType) {
    return pipelines.filter!(p => p.sourceType == sourceType).array;
  }
  Pipeline[] findBySource(TenantId tenantId, PipelineSourceType sourceType) {
    return findByTenant(tenantId).filter!(p => p.sourceType == sourceType).array;
  }
  void removeBySource(TenantId tenantId, PipelineSourceType sourceType) {
    findBySource(tenantId, sourceType).each!(p => remove(p));
  }

}
