/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.memory.pipelines;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class MemoryPipelineRepository : PipelineRepository {
  private Pipeline[string] _store;

  override void save(Pipeline entity)              { _store[entity.id.value] = entity; }
  override void update(Pipeline entity)            { _store[entity.id.value] = entity; }
  override void remove(string tenantId, PipelineId id) { _store.remove(id.value); }

  override Pipeline findById(string tenantId, PipelineId id) {
    if (id.value in _store) return _store[id.value];
    Pipeline p; return p;
  }

  override Pipeline[] findByTenant(string tenantId) {
    Pipeline[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId) result ~= p;
    return result;
  }

  override Pipeline[] findByProject(string tenantId, string projectId) {
    Pipeline[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.projectId.value == projectId) result ~= p;
    return result;
  }

  override Pipeline[] findByStage(string tenantId, PipelineStage stage) {
    Pipeline[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.stage == stage) result ~= p;
    return result;
  }

  override Pipeline[] findActive(string tenantId) {
    Pipeline[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.isActive) result ~= p;
    return result;
  }
}
