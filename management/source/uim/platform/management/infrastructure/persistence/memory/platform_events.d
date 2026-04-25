/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.platform_events;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.platform_events;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class MemoryPlatformEventRepository : IdRepository!(PlatformEvent, PlatformEventId), PlatformEventRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryPlatformEventRepository, PlatformEvent, PlatformEventId);

  // #region ByGlobalAccount
  size_t countByGlobalAccount(GlobalAccountId globalAccountId) {
    return findByGlobalAccount(globalAccountId).length;
  }

  PlatformEvent[] filterByGlobalAccount(PlatformEvent[] items, GlobalAccountId globalAccountId) {
    return items.filter!(e => e.globalAccountId == globalAccountId).array;
  }

  PlatformEvent[] findByGlobalAccount(GlobalAccountId globalAccountId) {
    return filterByGlobalAccount(findAll(), globalAccountId);
  }

  void removeByGlobalAccount(GlobalAccountId globalAccountId) {
    findByGlobalAccount(globalAccountId).each!(e => remove(e));
  }
  // #endregion ByGlobalAccount

  // #region BySubaccount
  size_t countBySubaccount(SubaccountId subaccountId) {
    return findBySubaccount(subaccountId).length;
  }

  PlatformEvent[] filterBySubaccount(PlatformEvent[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  PlatformEvent[] findBySubaccount(SubaccountId subaccountId) {
    return findAll().filter!(e => e.subaccountId == subaccountId).array;
  }

  void removeBySubaccount(SubaccountId subaccountId) {
    findBySubaccount(subaccountId).each!(e => remove(e));
  }
  // #endregion BySubaccount

  // #region ByCategory
  size_t countByCategory(GlobalAccountId globalAccountId, PlatformEventCategory category) {
    return findByCategory(globalAccountId, category).length;
  }

  PlatformEvent[] filterByCategory(PlatformEvent[] items, GlobalAccountId globalAccountId, PlatformEventCategory category) {
    return items.filter!(e => e.globalAccountId == globalAccountId
        && e.category == category).array;
  }

  PlatformEvent[] findByCategory(GlobalAccountId globalAccountId, PlatformEventCategory category) {
    return findAll().filter!(e => e.globalAccountId == globalAccountId
        && e.category == category).array;
  }

  void removeByCategory(GlobalAccountId globalAccountId, PlatformEventCategory category) {
    findByCategory(globalAccountId, category).each!(e => remove(e));
  }
  // #endregion ByCategory

  // #region BySeverity
  size_t countBySeverity(GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    return findBySeverity(globalAccountId, severity).length;
  }

  PlatformEvent[] filterBySeverity(PlatformEvent[] items, GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    return items.filter!(e => e.globalAccountId == globalAccountId
        && e.severity == severity).array;
  }

  PlatformEvent[] findBySeverity(GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    return findAll().filter!(e => e.globalAccountId == globalAccountId
        && e.severity == severity).array;
  }
  
  void removeBySeverity(GlobalAccountId globalAccountId, PlatformEventSeverity severity) {
    findBySeverity(globalAccountId, severity).each!(e => remove(e));
  }
  // #endregion BySeverity

  // #region Since
  size_t countSince(GlobalAccountId globalAccountId, long sinceTimestamp) {
    return findSince(globalAccountId, sinceTimestamp).length;
  }

  PlatformEvent[] filterSince(PlatformEvent[] items, GlobalAccountId globalAccountId, long sinceTimestamp) {
    return items.filter!(e => e.globalAccountId == globalAccountId
        && e.timestamp >= sinceTimestamp).array;
  }

  PlatformEvent[] findSince(GlobalAccountId globalAccountId, long sinceTimestamp) {
    return findAll().filter!(e => e.globalAccountId == globalAccountId
        && e.timestamp >= sinceTimestamp).array;
  }

  void removeSince(GlobalAccountId globalAccountId, long sinceTimestamp) {
    findSince(globalAccountId, sinceTimestamp).each!(e => remove(e));
  }
  // #endregion Since

}
