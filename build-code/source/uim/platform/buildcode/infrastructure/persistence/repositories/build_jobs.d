/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.build_jobs;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

class MemoryBuildJobRepository : BuildJobRepository {
  private BuildJob[string] _store;

  override void save(BuildJob entity)               { _store[entity.id.value] = entity; }
  override void update(BuildJob entity)             { _store[entity.id.value] = entity; }
  override void remove(TenantId tenantId, BuildJobId id) { _store.remove(id.value); }

  override BuildJob findById(TenantId tenantId, BuildJobId id) {
    if (id.value in _store) return _store[id.value];
    BuildJob j; return j;
  }

  override BuildJob[] findByTenant(TenantId tenantId) {
    BuildJob[] result;
    foreach (j; _store.byValue)
      if (j.tenantId == tenantId) result ~= j;
    return result;
  }

  override BuildJob[] findByPipeline(TenantId tenantId, string pipelineId) {
    BuildJob[] result;
    foreach (j; _store.byValue)
      if (j.tenantId == tenantId && j.pipelineId.value == pipelineId) result ~= j;
    return result;
  }

  override BuildJob[] findByProject(TenantId tenantId, string projectId) {
    BuildJob[] result;
    foreach (j; _store.byValue)
      if (j.tenantId == tenantId && j.projectId.value == projectId) result ~= j;
    return result;
  }

  override BuildJob[] findByStatus(TenantId tenantId, JobStatus status) {
    BuildJob[] result;
    foreach (j; _store.byValue)
      if (j.tenantId == tenantId && j.status == status) result ~= j;
    return result;
  }

  override BuildJob[] findByBranch(TenantId tenantId, string branch) {
    BuildJob[] result;
    foreach (j; _store.byValue)
      if (j.tenantId == tenantId && j.branch == branch) result ~= j;
    return result;
  }
}
