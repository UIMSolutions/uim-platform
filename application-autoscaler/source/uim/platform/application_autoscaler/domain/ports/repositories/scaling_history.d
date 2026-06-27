/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.scaling_history;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

interface ScalingHistoryRepository : ITenantRepository!(ScalingHistory, ScalingHistoryId) {

  size_t countByApp(TenantId tenantId, AppBindingId appId);
  ScalingHistory[] findByApp(TenantId tenantId, AppBindingId appId);
  void removeByApp(TenantId tenantId, AppBindingId appId);

  size_t countByAppIdSince(TenantId tenantId, AppBindingId appId, long sinceTimestamp);
  ScalingHistory[] findByAppIdSince(TenantId tenantId, AppBindingId appId, long sinceTimestamp);
  void removeByAppIdSince(TenantId tenantId, AppBindingId appId, long sinceTimestamp);
  
}
