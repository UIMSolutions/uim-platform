/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.memory.devspaces;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class MemoryDevSpaceRepository : DevSpaceRepository {
  private DevSpace[string] _store;

  override void save(DevSpace entity)             { _store[entity.id.value] = entity; }
  override void update(DevSpace entity)           { _store[entity.id.value] = entity; }
  override void remove(TenantId tenantId, DevSpaceId id) { _store.remove(id.value); }

  override DevSpace findById(TenantId tenantId, DevSpaceId id) {
    if (id.value in _store) return _store[id.value];
    DevSpace ds; return ds;
  }

  override DevSpace[] findByTenant(TenantId tenantId) {
    DevSpace[] result;
    foreach (ds; _store.byValue)
      if (ds.tenantId == tenantId) result ~= ds;
    return result;
  }

  override DevSpace[] findByProject(TenantId tenantId, string projectId) {
    DevSpace[] result;
    foreach (ds; _store.byValue)
      if (ds.tenantId == tenantId && ds.projectId.value == projectId) result ~= ds;
    return result;
  }

  override DevSpace[] findByStatus(TenantId tenantId, DevSpaceStatus status) {
    DevSpace[] result;
    foreach (ds; _store.byValue)
      if (ds.tenantId == tenantId && ds.status == status) result ~= ds;
    return result;
  }
}
