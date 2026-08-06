/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.usecases.monitor_activities;

// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;


import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Application service for viewing content operation activities.
interface IMonitorActivitiesUseCase { 

  ContentActivity[] listActivities(TenantId tenantId); 
  ContentActivity[] listByEntity(TenantId tenantId, string entityId);
  ContentActivity[] listByType(TenantId tenantId, string activityTypeStr);
  ActivitySummary getSummary(TenantId tenantId);

}
