/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.subaccounts;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.ports.repositories.subaccounts;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemorySubaccountRepository : IdRepository!(Subaccount, SubaccountId), SubaccountRepository {

  // #region BySubdomain
  bool existsBySubdomain(string subdomain) {
    return findAll.any!(s => s.subdomain == subdomain);
  }

  Subaccount findBySubdomain(string subdomain) {
    foreach (s; findAll()) {
      if (s.subdomain == subdomain)
        return s;
    }
    return Subaccount.init;
  }
  // #endregion BySubdomain

  // #region ByGlobalAccount
  size_t countByGlobalAccount(GlobalAccountId globalAccountId) {
    return findByGlobalAccount(globalAccountId).length;
  }

  Subaccount[] filterByGlobalAccount(Subaccount[] subs, GlobalAccountId globalAccountId) {
    return subs.filter!(s => s.globalAccountId == globalAccountId).array;
  }

  Subaccount[] findByGlobalAccount(GlobalAccountId globalAccountId) {
    return filterByGlobalAccount(findAll(), globalAccountId);
  }

  void removeByGlobalAccount(GlobalAccountId globalAccountId) {
    findByGlobalAccount(globalAccountId).each!(e => remove(e));
  }
  // #endregion ByGlobalAccount

  // #region ByDirectory
  size_t countByDirectory(DirectoryId directoryId) {
    return findByDirectory(directoryId).length;
  }

  Subaccount[] filterByDirectory(Subaccount[] subs, DirectoryId directoryId) {
    return subs.filter!(s => s.parentDirectoryId == directoryId).array;
  } 
  
  Subaccount[] findByDirectory(DirectoryId directoryId) {
    return filterByDirectory(findAll(), directoryId);
  }

  void removeByDirectory(DirectoryId directoryId) {
    findByDirectory(directoryId).each!(e => remove(e));
  }
  // #endregion ByDirectory

  // #region ByRegion
  size_t countByRegion(GlobalAccountId globalAccountId, string region) {
    return findByRegion(globalAccountId, region).length;
  }
  Subaccount[] filterByRegion(Subaccount[] subs, GlobalAccountId globalAccountId, string region) {
    return subs.filter!(s => s.globalAccountId == globalAccountId && s.region == region).array;
  }

  Subaccount[] findByRegion(GlobalAccountId globalAccountId, string region) {
    return filterByRegion(findAll(), globalAccountId, region);
  }

  void removeByRegion(GlobalAccountId globalAccountId, string region) {
    findByRegion(globalAccountId, region).each!(e => remove(e));
  }
  // #endregion ByRegion

  // #region ByStatus
  size_t countByStatus(GlobalAccountId globalAccountId, SubaccountStatus status) {
    return findByStatus(globalAccountId, status).length;
  }

  Subaccount[] filterByStatus(Subaccount[] subs, GlobalAccountId globalAccountId, SubaccountStatus status) {
    return subs.filter!(s => s.globalAccountId == globalAccountId && s.status == status).array;
  }

  Subaccount[] findByStatus(GlobalAccountId globalAccountId, SubaccountStatus status) {
    return filterByStatus(findAll(), globalAccountId, status);
  }

  void removeByStatus(GlobalAccountId globalAccountId, SubaccountStatus status) {
    findByStatus(globalAccountId, status).each!(e => remove(e));
  }
  // #endregion ByStatus
  
}
