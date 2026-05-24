/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.platform_events;
// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.platform_events;
// 
//  

import uim.platform.management;

mixin(ShowModule!());
@safe:
class MemoryPlatformEventRepository : TenantRepository!(PlatformEvent, PlatformEventId), PlatformEventRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryPlatformEventRepository, PlatformEvent, PlatformEventId);

  // #region ByGlobalAccount
  size_t countByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return findByGlobalAccount(tenantId, globalAccountId).length;
  }

  PlatformEvent[] filterByGlobalAccount(PlatformEvent[] items, GlobalAccountId globalAccountId) {
    return items.filter!(e => e.globalAccountId == globalAccountId).array;
  }

  PlatformEvent[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return filterByGlobalAccount(findByTenant(tenantId), globalAccountId);
  }

  void removeByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    findByGlobalAccount(tenantId, globalAccountId).each!(e => remove(e));
  }
  // #endregion ByGlobalAccount

  // #region BySubaccount
  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  PlatformEvent[] filterBySubaccount(PlatformEvent[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  PlatformEvent[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }
  // #endregion BySubaccount

  // #region ByCategory
  size_t countByCategory(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventCategory category) {
    return findByCategory(tenantId, globalAccountId, category).length;
  }

  PlatformEvent[] filterByCategory(PlatformEvent[] items, PlatformEventCategory category) {
    return items.filter!(e => e.category == category).array;
  }

  PlatformEvent[] findByCategory(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventCategory category) {
    return filterByCategory(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), category);
  }

  void removeByCategory(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventCategory category) {
    findByCategory(tenantId, globalAccountId, category).each!(e => remove(e));
  }
  // #endregion ByCategory

  // #region BySeverity
  size_t countBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    return findBySeverity(tenantId, globalAccountId, severity).length;
  }

  PlatformEvent[] filterBySeverity(PlatformEvent[] items, PlatformEventSeverity severity) {
    return items.filter!(e => e.severity == severity).array;
  }

  PlatformEvent[] findBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    return filterBySeverity(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), severity);
  }
  
  void removeBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    findBySeverity(tenantId, globalAccountId, severity).each!(e => remove(e));
  }
  // #endregion BySeverity

  // #region Since
  size_t countSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp) {
    return findSince(tenantId, globalAccountId, sinceTimestamp).length;
  }

  PlatformEvent[] filterSince(PlatformEvent[] items, long sinceTimestamp) {
    return items.filter!(e => e.timestamp >= sinceTimestamp).array;
  }

  PlatformEvent[] findSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp) {
    return filterSince(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), sinceTimestamp);
  }

  void removeSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp) {
    findSince(tenantId, globalAccountId, sinceTimestamp).each!(e => remove(e));
  }
  // #endregion Since

}
