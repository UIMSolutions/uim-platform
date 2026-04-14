/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositoriess;

// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IRepositoryRepository {
  Repository[] findByTenant(TenantId tenantId);
  Repository findById(RepositoryId tenantId, id tenantId);
  Repository findByName(string name, TenantId tenantId);
  Repository[] findByStatus(RepositoryStatus status, TenantId tenantId);
  void save(Repository repo);
  void update(Repository repo);
  void remove(RepositoryId tenantId, id tenantId);
}
