/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.content_activitys;

import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - content activity (audit log) persistence.
interface ContentActivityRepository
{
  ContentActivity findById(ContentActivityId id);
  ContentActivity[] findByTenant(TenantId tenantId);
  ContentActivity[] findByEntity(string entityId);
  ContentActivity[] findByType(TenantId tenantId, ActivityType activityType);
  ContentActivity[] findRecent(TenantId tenantId, int limit);
  void save(ContentActivity activity);
}
