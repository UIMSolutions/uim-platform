/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface ScalingPolicyRepository : ITenantRepository!(ScalingPolicyEntity, PolicyId) {

  size_t countByApp(TenantId tenantId, AppBindingId appId);
  ScalingPolicyEntity findByApp(TenantId tenantId, AppBindingId appId);
  void removeByApp(TenantId tenantId, AppBindingId appId);
  
}
