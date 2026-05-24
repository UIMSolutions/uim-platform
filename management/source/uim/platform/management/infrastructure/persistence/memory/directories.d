/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.directories;
// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.ports.repositories.directorys;
// 
//  

import uim.platform.management;

mixin(ShowModule!());
@safe:
class MemoryDirectoryRepository : TenantRepository!(Directory, DirectoryId), DirectoryRepository {

  // #region ByGlobalAccount
  size_t countByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return findByGlobalAccount(tenantId, globalAccountId).length;
  }

  Directory[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return filterByGlobalAccount(findByTenant(tenantId), globalAccountId);
  }

  void removeByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    findByGlobalAccount(tenantId, globalAccountId).each!(d => remove(d));
  }
  // #endregion ByGlobalAccount

  // #region ByParent
  size_t countByParent(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryId parentDirectoryId) {
    return findByParent(tenantId, globalAccountId, parentDirectoryId).length;
  }

  Directory[] filterByParent(Directory[] dirs, DirectoryId parentDirectoryId) {
    return dirs.filter!(d => d.parentDirectoryId == parentDirectoryId).array;
  }

  Directory[] findByParent(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryId parentDirectoryId) {
    return filterByParent(findByGlobalAccount(tenantId, globalAccountId), parentDirectoryId);
  }

  void removeByParent(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryId parentDirectoryId) {
    findByParent(tenantId, globalAccountId, parentDirectoryId).each!(d => remove(d));
  }

  // #endregion ByParent

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryStatus status) {
    return findByStatus(tenantId, globalAccountId, status).length;
  }

  Directory[] filterByStatus(Directory[] dirs, DirectoryStatus status) {
    return dirs.filter!(d => d.status == status).array;
  }

  Directory[] findByStatus(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryStatus status) {
    return filterByStatus(findByGlobalAccount(tenantId, globalAccountId), status);
  }

  void removeByStatus(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryStatus status) {
    findByStatus(tenantId, globalAccountId, status).each!(d => remove(d));
  }
  // #endregion ByStatus

}
