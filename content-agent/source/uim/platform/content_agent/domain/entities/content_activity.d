/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.content_activity;

import uim.platform.content_agent.domain.types;

/// Audit record for a content operation.
struct ContentActivity {
  ContentActivityId id;
  TenantId tenantId;
  ActivityType activityType;
  ActivitySeverity severity = ActivitySeverity.info;
  string entityId;
  string entityName;
  string description;
  string performedBy;
  long timestamp;
  string details;
}
