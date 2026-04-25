/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.directories;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.ports.repositories.directorys;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class MemoryDirectoryRepository : DirectoryRepository {
  private Directory[DirectoryId] store;

  // #region ById
  bool existsById(DirectoryId id) {
    return (id in store) ? true : false;
  }

  Directory findById(DirectoryId id) {
    return existsById(id) ? store[id] : Directory.init;
  }
  // #endregion ById

  // #region ByGlobalAccount
  size_t countByGlobalAccount(GlobalAccountId globalAccountId) {
    return findByGlobalAccount(globalAccountId).length;
  }

  Directory[] filterByGlobalAccount(Directory[] dirs, GlobalAccountId globalAccountId) {
    return dirs.filter!(d => d.globalAccountId == globalAccountId).array;
  }

  Directory[] findByGlobalAccount(GlobalAccountId globalAccountId) {
    return findAll.filterByGlobalAccount(globalAccountId);
  }

  void removeByGlobalAccount(GlobalAccountId globalAccountId) {
    findByGlobalAccount(globalAccountId).removeAll;
  }
  // #endregion ByGlobalAccount

  // #region ByParent
  size_t countByParent(DirectoryId parentDirectoryId) {
    return findByParent(parentDirectoryId).length;
  }

  Directory[] filterByParent(Directory[] dirs, DirectoryId parentDirectoryId) {
    return dirs.filter!(d => d.parentDirectoryId == parentDirectoryId).array;
  }

  Directory[] findByParent(DirectoryId parentDirectoryId) {
    return findAll.filterByParent(parentDirectoryId);
  }

  void removeByParent(DirectoryId parentDirectoryId) {
    findByParent(parentDirectoryId).removeAll;
  }
  
  // #endregion ByParent

  // #region ByStatus
  Directory[] findByStatus(GlobalAccountId globalAccountId, DirectoryStatus status) {
    return findAll.filterByStatus(globalAccountId, status).array;
  }
  // #endregion ByStatus

  void save(Directory dir) {
    store[dir.id] = dir;
  }

  void update(Directory dir) {
    store[dir.id] = dir;
  }

  void remove(DirectoryId id) {
    store.remove(id);
  }
}
