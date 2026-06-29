/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.directories;

// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.ports.repositories.directorys;
// 
//  

import uim.platform.management;

// mixin(ShowModule!());
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
  size_t countByParent(TenantId tenantId, DirectoryId parentDirectoryId) {
    return findByParent(tenantId, parentDirectoryId).length;
  }

  Directory[] filterByParent(Directory[] dirs, DirectoryId parentDirectoryId) {
    return dirs.filter!(d => d.parentDirectoryId == parentDirectoryId).array;
  }

  Directory[] findByParent(TenantId tenantId, DirectoryId parentDirectoryId) {
    return filterByParent(findByTenant(tenantId), parentDirectoryId);
  }

  void removeByParent(TenantId tenantId, DirectoryId parentDirectoryId) {
    findByParent(tenantId, parentDirectoryId).each!(d => remove(d));
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
/// 
unittest {
  auto repo = new MemoryDirectoryRepository();

  auto tenantId = TenantId("tenant1");
  auto gaId = GlobalAccountId("ga1");
  auto parentDirId = DirectoryId("parent1");

  // Create directories
  auto dir1 = Directory(tenantId);
  dir1.id = DirectoryId("dir1");
  dir1.globalAccountId = gaId;
  dir1.parentDirectoryId = parentDirId;
  dir1.displayName = "Directory 1";
  dir1.description = "Description 1";
  dir1.status = DirectoryStatus.active;

  auto dir2 = Directory(tenantId);
  dir2.id = DirectoryId("dir2");
  dir2.globalAccountId = gaId;
  dir2.parentDirectoryId = parentDirId;
  dir2.displayName = "Directory 2";
  dir2.description = "Description 2";
  dir2.status = DirectoryStatus.inactive;

  repo.save(dir1);
  repo.save(dir2);

  // Test findByGlobalAccount
  auto dirsByGA = repo.findByGlobalAccount(tenantId, gaId);
  assert(dirsByGA.length == 2);

  // Test findByParent
  auto dirsByParent = repo.findByParent(tenantId, parentDirId);
  assert(dirsByParent.length == 2);

  // Test findByStatus
  auto activeDirs = repo.findByStatus(tenantId, gaId, DirectoryStatus.active);
  assert(activeDirs.length == 1);
  assert(activeDirs[0].id == dir1.id);

  // Test removeByStatus
  repo.removeByStatus(tenantId, gaId, DirectoryStatus.active);
  activeDirs = repo.findByStatus(tenantId, gaId, DirectoryStatus.active);
  assert(activeDirs.length == 0);
}
