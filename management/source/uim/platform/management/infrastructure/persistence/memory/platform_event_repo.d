/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.platform_event_repo;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.platform_events;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class MemoryPlatformEventRepository : PlatformEventRepository {
  private PlatformEvent[PlatformEventId] store;

  PlatformEvent findById(PlatformEventId id)
  {
    if (auto p = id in store)
      return *p;
    return PlatformEvent.init;
  }

  PlatformEvent[] findByGlobalAccount(GlobalAccountId globalAccountId)
  {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId).array;
  }

  PlatformEvent[] findBySubaccount(SubaccountId subaccountId)
  {
    return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
  }

  PlatformEvent[] findByCategory(GlobalAccountId globalAccountId, PlatformEventCategory category)
  {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId
        && e.category == category).array;
  }

  PlatformEvent[] findBySeverity(GlobalAccountId globalAccountId, PlatformEventSeverity severity)
  {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId
        && e.severity == severity).array;
  }

  PlatformEvent[] findSince(GlobalAccountId globalAccountId, long sinceTimestamp)
  {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId
        && e.timestamp >= sinceTimestamp).array;
  }

  void save(PlatformEvent event)
  {
    store[event.id] = event;
  }

  void remove(PlatformEventId id)
  {
    store.remove(id);
  }
}
