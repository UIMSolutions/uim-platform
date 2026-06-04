/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.subaccounts;

// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.ports.repositories.subaccounts;
// 
//  

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemorySubaccountRepository : TenantRepository!(Subaccount, SubaccountId), SubaccountRepository {

  // #region BySubdomain
  bool existsBySubdomain(TenantId tenantId, string subdomain) {
    return findByTenant(tenantId).any!(s => s.subdomain == subdomain);
  }

  Subaccount findBySubdomain(TenantId tenantId, string subdomain) {
    foreach (s; findByTenant(tenantId)) {
      if (s.subdomain == subdomain)
        return s;
    }
    return Subaccount.init;
  }
  // #endregion BySubdomain

  // #region ByGlobalAccount
  size_t countByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return findByGlobalAccount(tenantId, globalAccountId).length;
  }

  Subaccount[] filterByGlobalAccount(Subaccount[] subs, GlobalAccountId globalAccountId) {
    return subs.filter!(s => s.globalAccountId == globalAccountId).array;
  }

  Subaccount[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return filterByGlobalAccount(findByTenant(tenantId), globalAccountId);
  }

  void removeByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    findByGlobalAccount(tenantId, globalAccountId).each!(e => remove(e));
  }
  // #endregion ByGlobalAccount

  // #region ByDirectory
  size_t countByDirectory(TenantId tenantId, DirectoryId directoryId) {
    return findByDirectory(tenantId, directoryId).length;
  }

  Subaccount[] filterByDirectory(Subaccount[] subs, DirectoryId directoryId) {
    return subs.filter!(s => s.parentDirectoryId == directoryId).array;
  } 
  
  Subaccount[] findByDirectory(TenantId tenantId, DirectoryId directoryId) {
    return filterByDirectory(findByTenant(tenantId), directoryId);
  }

  void removeByDirectory(TenantId tenantId, DirectoryId directoryId) {
    findByDirectory(tenantId, directoryId).each!(e => remove(e));
  }
  // #endregion ByDirectory

  // #region ByRegion
  size_t countByRegion(TenantId tenantId, GlobalAccountId globalAccountId, string region) {
    return findByRegion(tenantId, globalAccountId, region).length;
  }
  Subaccount[] filterByRegion(Subaccount[] subs, string region) {
    return subs.filter!(s => s.region == region).array;
  }

  Subaccount[] findByRegion(TenantId tenantId, GlobalAccountId globalAccountId, string region) {
    return filterByRegion(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), region);
  }

  void removeByRegion(TenantId tenantId, GlobalAccountId globalAccountId, string region) {
    findByRegion(tenantId, globalAccountId, region).each!(e => remove(e));
  }
  // #endregion ByRegion

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, GlobalAccountId globalAccountId, SubaccountStatus status) {
    return findByStatus(tenantId, globalAccountId, status).length;
  }

  Subaccount[] filterByStatus(Subaccount[] subs, SubaccountStatus status) {
    return subs.filter!(s => s.status == status).array;
  }

  Subaccount[] findByStatus(TenantId tenantId, GlobalAccountId globalAccountId, SubaccountStatus status) {
    return filterByStatus(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), status);
  }

  void removeByStatus(TenantId tenantId, GlobalAccountId globalAccountId, SubaccountStatus status) {
    findByStatus(tenantId, globalAccountId, status).each!(e => remove(e));
  }
  // #endregion ByStatus
  
}
