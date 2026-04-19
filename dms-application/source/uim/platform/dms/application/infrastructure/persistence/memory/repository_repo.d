/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.repository;

// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.ports.repositoriess;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class MemoryRepositoryRepository : IRepositoryRepository {
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }

  Repository findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return null;
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).each!(e => store.remove(e.tenantId, e.id));
  }

  size_t countByStatus(TenantId tenantId, RepositoryStatus status) {
    return findByStatus(tenantId, status).count;
  }

  Repository[] findByStatus(TenantId tenantId, RepositoryStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, RepositoryStatus status) {
    findByStatus(tenantId, status).each!(e => store.remove(e.tenantId, e.id));
  }
}
