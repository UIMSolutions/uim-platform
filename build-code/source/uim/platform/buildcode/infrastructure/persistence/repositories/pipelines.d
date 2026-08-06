/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.pipelines;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class PipelineRepository : TenantRepository!(Pipeline, PipelineId), IPipelineRepository {

  size_t countByProject(TenantId tenantId, string projectId) {
    return findByProject(tenantId, projectId).length;
  }

  Pipeline[] filterByProject(Pipeline[] pipelines, string projectId) {
    return pipelines.filter!(p => p.projectId.value == projectId).array;
  }

  Pipeline[] findByProject(TenantId tenantId, string projectId) {
    return filterByProject(findByTenant(tenantId), projectId);
  }

  void removeByProject(TenantId tenantId, string projectId) {
    findByProject(tenantId, projectId).each!(p => remove(p));
  }

  size_t countByStage(TenantId tenantId, PipelineStage stage) {
    return findByStage(tenantId, stage).length;
  }

  Pipeline[] filterByStage(Pipeline[] pipelines, PipelineStage stage) {
    return pipelines.filter!(p => p.stage == stage).array;
  }

  override Pipeline[] findByStage(TenantId tenantId, PipelineStage stage) {
    return filterByStage(findByTenant(tenantId), stage);
  }

  void removeByStage(TenantId tenantId, PipelineStage stage) {
    findByStage(tenantId, stage).each!(p => remove(p));
  }

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }
  
  Pipeline[] filterActive(Pipeline[] pipelines) {
    return pipelines.filter!(p => p.isActive).array;
  }
  
  Pipeline[] findActive(TenantId tenantId) {
    return filterActive(findByTenant(tenantId));
  }

  void removeActive(TenantId tenantId) {
    findActive(tenantId).each!(p => remove(p));
  }

}
