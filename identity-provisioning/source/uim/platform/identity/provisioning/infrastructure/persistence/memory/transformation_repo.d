/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.transformation;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.transformation;
import uim.platform.identity.provisioning.domain.ports.repositories.transformations;

class MemoryTransformationRepository : TransformationRepository {
  private Transformation[string] store;

  void save(Transformation entity) {
    store[entity.id] = entity;
  }

  void update(Transformation entity) {
    store[entity.id] = entity;
  }

  void remove(TransformationId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  Transformation* findById(TransformationId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Transformation[] findByTenant(TenantId tenantId) {
    Transformation[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Transformation[] findBySystem(string systemId, TenantId tenantId) {
    Transformation[] result;
    foreach (ref e; store)
      if (e.systemId == systemId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Transformation[] findBySystemRole(TenantId tenantId, SystemRole role) {
    Transformation[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.systemRole == role)
        result ~= e;
    return result;
  }
}
