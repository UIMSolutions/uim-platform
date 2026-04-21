/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.content_activitys;

// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:

/// Port: outgoing - content activity (audit log) persistence.
interface ContentActivityRepository : ITenantRepository!(ContentActivity, ContentActivityId) {
  
  size_t countByEntity(string entityId);
  ContentActivity[] findByEntity(string entityId);
  void removeByEntity(string entityId);

  size_t countByType(TenantId tenantId, ActivityType activityType);
  ContentActivity[] findByType(TenantId tenantId, ActivityType activityType);
  void removeByType(TenantId tenantId, ActivityType activityType);
  
  size_t countRecent(TenantId tenantId, int limit);
  ContentActivity[] findRecent(TenantId tenantId, int limit);
  void removeRecent(TenantId tenantId, int limit);
  
}
