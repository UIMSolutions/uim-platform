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
  private Repository[string] store;

  Repository[] findByTenant(TenantId tenantId) {
    Repository[] result;
    foreach (e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Repository findById(RepositoryId tenantId, id tenantId) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Repository findByName(string name, TenantId tenantId) {
    foreach (e; store)
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return null;
  }

  Repository[] findByStatus(RepositoryStatus status, TenantId tenantId) {
    Repository[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  void save(Repository repo) {
    store[repo.id] = repo;
  }

  void update(Repository repo) {
    store[repo.id] = repo;
  }

  void remove(RepositoryId tenantId, id tenantId) {
    store.remove(id);
  }
}
