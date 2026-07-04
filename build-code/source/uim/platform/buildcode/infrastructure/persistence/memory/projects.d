/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.memory.projects;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class MemoryProjectRepository : ProjectRepository {
  private Project[string] _store;

  override void save(Project entity) {
    _store[entity.id.value] = entity;
  }

  override void update(Project entity) {
    _store[entity.id.value] = entity;
  }

  override void remove(TenantId tenantId, ProjectId id) {
    _store.remove(id.value);
  }

  override Project findById(TenantId tenantId, ProjectId id) {
    if (id.value in _store) return _store[id.value];
    Project p;
    return p;
  }

  override Project[] findByTenant(TenantId tenantId) {
    Project[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId) result ~= p;
    return result;
  }

  override Project[] findByStatus(TenantId tenantId, ProjectStatus status) {
    Project[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.status == status) result ~= p;
    return result;
  }

  override Project[] findByType(TenantId tenantId, ProjectType type) {
    Project[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.type == type) result ~= p;
    return result;
  }

  override Project[] findByOwner(TenantId tenantId, string ownerEmail) {
    Project[] result;
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.ownerEmail == ownerEmail) result ~= p;
    return result;
  }

  override bool nameExists(TenantId tenantId, string name) {
    foreach (p; _store.byValue)
      if (p.tenantId == tenantId && p.name == name) return true;
    return false;
  }
}
