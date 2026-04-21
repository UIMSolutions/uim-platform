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
class MemoryContentActivityRepository : TenantRepository!(ContentActivity, ContentActivityId), ContentActivityRepository {

  // #region byEntity
  size_t countByEntity(string entityId) {
    return findByEntity(entityId).length;
  }  

  ContentActivity[] findByEntity(string entityId) {
    return findAll.filter!(e => e.entityId == entityId).array;
  }

  void removeByEntity(string entityId) {
    findByEntity(entityId).each!(e => remove(e));
  }
  // #endregion byEntity

  // #region byType
  size_t countByType(TenantId tenantId, ActivityType activityType) {
    return findByType(tenantId, activityType).length;
  }

  ContentActivity[] findByType(TenantId tenantId, ActivityType activityType) {
    return findByTenant(tenantId).filter!(e => e.activityType == activityType).array;
  }

  void removeByType(TenantId tenantId, ActivityType activityType) {
    findByType(tenantId, activityType).each!(e => remove(e));
  }
  // #endregion byType

  // #region recent
  // Recent activities
  size_t countRecent(TenantId tenantId, int limit) {
    return findRecent(tenantId, limit).length;
  }

  ContentActivity[] findRecent(TenantId tenantId, int limit) {
    auto filtered = findByTenant(tenantId).sort!((a, b) => a.timestamp > b.timestamp);
    if (filtered.length > limit)
      return filtered[0 .. limit];
    return filtered;
  }

  void removeRecent(TenantId tenantId, int limit) {
    findRecent(tenantId, limit).each!(e => remove(e));
  }
  // #endregion recent
}
