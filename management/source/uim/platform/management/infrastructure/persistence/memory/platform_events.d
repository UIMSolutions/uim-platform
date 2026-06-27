/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.platform_events;

// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.platform_events;
// 
//  

import uim.platform.management;

// mixin(ShowModule!());
@safe:
class MemoryEnvironmentEventRepository : TentRepository!(EnvironmentEvent, EnvironmentEventId), EnvironmentEventRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryEnvironmentEventRepository, EnvironmentEvent, EnvironmentEventId);

  // #region ByGlobalAccount
  size_t countByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return findByGlobalAccount(tenantId, globalAccountId).length;
  }

  EnvironmentEvent[] filterByGlobalAccount(EnvironmentEvent[] items, GlobalAccountId globalAccountId) {
    return items.filter!(e => e.globalAccountId == globalAccountId).array;
  }

  EnvironmentEvent[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
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

  EnvironmentEvent[] filterBySubaccount(EnvironmentEvent[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  EnvironmentEvent[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }
  // #endregion BySubaccount

  // #region ByCategory
  size_t countByCategory(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventCategory category) {
    return findByCategory(tenantId, globalAccountId, category).length;
  }

  EnvironmentEvent[] filterByCategory(EnvironmentEvent[] items, EnvironmentEventCategory category) {
    return items.filter!(e => e.category == category).array;
  }

  EnvironmentEvent[] findByCategory(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventCategory category) {
    return filterByCategory(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), category);
  }

  void removeByCategory(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventCategory category) {
    findByCategory(tenantId, globalAccountId, category).each!(e => remove(e));
  }
  // #endregion ByCategory

  // #region BySeverity
  size_t countBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventSeverity severity) {
    return findBySeverity(tenantId, globalAccountId, severity).length;
  }

  EnvironmentEvent[] filterBySeverity(EnvironmentEvent[] items, EnvironmentEventSeverity severity) {
    return items.filter!(e => e.severity == severity).array;
  }

  EnvironmentEvent[] findBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventSeverity severity) {
    return filterBySeverity(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), severity);
  }
  
  void removeBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventSeverity severity) {
    findBySeverity(tenantId, globalAccountId, severity).each!(e => remove(e));
  }
  // #endregion BySeverity

  // #region Since
  size_t countSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp) {
    return findSince(tenantId, globalAccountId, sinceTimestamp).length;
  }

  EnvironmentEvent[] filterSince(EnvironmentEvent[] items, long sinceTimestamp) {
    return items.filter!(e => e.timestamp >= sinceTimestamp).array;
  }

  EnvironmentEvent[] findSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp) {
    return filterSince(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), sinceTimestamp);
  }

  void removeSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp) {
    findSince(tenantId, globalAccountId, sinceTimestamp).each!(e => remove(e));
  }
  // #endregion Since

}
