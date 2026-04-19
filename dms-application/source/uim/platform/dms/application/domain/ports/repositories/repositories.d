/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.repositories;

// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IRepositoryRepository : ITenantRepository!(Repository, RepositoryId) {
  bool existsByName(TenantId tenantId, string name);
  Repository findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByStatus(TenantId tenantId, RepositoryStatus status);
  Repository[] findByStatus(TenantId tenantId, RepositoryStatus status);
  void removeByStatus(TenantId tenantId, RepositoryStatus status);
}
