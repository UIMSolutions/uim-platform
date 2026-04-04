/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.dashboard;

// import uim.platform.analytics.domain.entities.dashboard;
// import uim.platform.analytics.domain.repositories.dashboard;
// import uim.platform.analytics.domain.values.common;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// In-memory adapter implementing DashboardRepository port.
class MemoryDashboardRepository : DashboardRepository {
  private Dashboard[string] store;

  Dashboard findById(EntityId id)
  {
    if (auto p = id.value in store)
      return *p;
    return null;
  }

  Dashboard[] findByOwner(EntityId ownerId)
  {
    Dashboard[] result;
    foreach (d; store.byValue())
      if (d.ownerId == ownerId)
        result ~= d;
    return result;
  }

  Dashboard[] findByStatus(ArtifactStatus status)
  {
    Dashboard[] result;
    foreach (d; store.byValue())
      if (d.status == status)
        result ~= d;
    return result;
  }

  Dashboard[] findAll()
  {
    return store.values;
  }

  void save(Dashboard dashboard)
  {
    store[dashboard.id.value] = dashboard;
  }

  void remove(EntityId id)
  {
    store.remove(id.value);
  }
}
