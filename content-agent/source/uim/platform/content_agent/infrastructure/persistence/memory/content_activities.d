/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.content_activities;

// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;

// import std.algorithm : filter, sort;
// import std.array : array;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class MemoryContentActivityRepository : ContentActivityRepository {
  private ContentActivity[] store;

  ContentActivity findById(ContentActivityId id) {
    foreach (e; store)
      if (e.id == id)
        return e;
    return ContentActivity.init;
  }

  ContentActivity[] findByTenant(TenantId tenantId) {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  ContentActivity[] findByEntity(string entityId) {
    return store.filter!(e => e.entityId == entityId).array;
  }

  ContentActivity[] findByType(TenantId tenantId, ActivityType activityType) {
    return store.filter!(e => e.tenantId == tenantId && e.activityType == activityType).array;
  }

  ContentActivity[] findRecent(TenantId tenantId, int limit) {
    auto filtered = store.filter!(e => e.tenantId == tenantId).array;
    filtered.sort!((a, b) => a.timestamp > b.timestamp);
    if (filtered.length > limit)
      return filtered[0 .. limit];
    return filtered;
  }

  void save(ContentActivity activity) {
    store ~= activity;
  }
}
