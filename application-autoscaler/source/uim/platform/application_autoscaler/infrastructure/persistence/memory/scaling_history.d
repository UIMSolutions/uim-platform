/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.scaling_history;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class MemoryScalingHistoryRepository : TenantRepository!(ScalingHistory, ScalingHistoryId), ScalingHistoryRepository {

  size_t countByApp(TenantId tenantId, AppBindingId appId) {
    return findByApp(tenantId, appId).length;
  }

  ScalingHistory[] filterByApp(ScalingHistory[] history, AppBindingId appId) {
    return history.filter!(e => e.appId == appId).array;
  }

  ScalingHistory[] findByApp(TenantId tenantId, AppBindingId appId) {
    return find(tenantId).filter!(e => e.appId == appId).array;
  }

  void removeByApp(TenantId tenantId, AppBindingId appId) {
    findByApp(tenantId, appId).each!(e => remove(e));
  }

  size_t countByAppIdSince(TenantId tenantId, AppBindingId appId, long sinceTimestamp) {
    return findByAppIdSince(tenantId, appId, sinceTimestamp).length;
  }

  ScalingHistory[] findByAppIdSince(TenantId tenantId, AppBindingId appId, long sinceTimestamp) {
    return findByApp(tenantId, appId).filter!(e => e.timestamp >= sinceTimestamp).array;
  }

  void removeByAppIdSince(TenantId tenantId, AppBindingId appId, long sinceTimestamp) {
    findByAppIdSince(tenantId, appId, sinceTimestamp).each!(e => remove(e));
  }

}
