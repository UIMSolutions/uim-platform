/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.repositories;
// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.ports.repositoriess;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

// mixin(ShowModule!());
@safe:
class MemoryRepositoryRepository : TenantRepository!(Repository, RepositoryId), IRepositoryRepository {
  // #region byName
  bool existsByName(TenantId tenantId, string name) {
    return find(tenantId).any!(e => e.name == name);
  }

  Repository findByName(TenantId tenantId, string name) {
    foreach (e; find(tenantId))
      if (e.name == name)
        return e;
    return Repository.init;
  }

  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }
  // #endregion byName

  // #region byStatus
  size_t countByStatus(TenantId tenantId, RepositoryStatus status) {
    return findByStatus(tenantId, status).count;
  }

  Repository[] filterByStatus(Repository[] repositories, RepositoryStatus status) {
    return repositories.filter!(e => e.status == status).array;
  }
  Repository[] findByStatus(TenantId tenantId, RepositoryStatus status) {
    return filterByStatus(find(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, RepositoryStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
  // #endregion byStatus
}
