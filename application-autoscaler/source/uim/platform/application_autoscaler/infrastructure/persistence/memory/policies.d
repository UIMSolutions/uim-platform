/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class MemoryScalingPolicyRepository : TenantRepository!(ScalingPolicyEntity, ScalingPolicyId), ScalingPolicyRepository {

  bool existsByApp(TenantId tenantId, AppBindingId appId) {
    return findByApp(tenantId, appId).isNull ? false : true;
  }

  ScalingPolicyEntity findByApp(TenantId tenantId, AppBindingId appId) {
    foreach (p; findByTenant(tenantId))
      if (p.appId == appId && p.status == PolicyStatus.active) return p;
    return ScalingPolicyEntity.init;
  }

  void removeByApp(TenantId tenantId, AppBindingId appId) {
    remove(findByApp(tenantId, appId));
  }
}
