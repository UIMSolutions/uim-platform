/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface ScalingPolicyRepository {
  bool                existsById(PolicyId id);
  ScalingPolicyEntity findById(PolicyId id);
  ScalingPolicyEntity findByAppId(AppBindingId appId);
  ScalingPolicyEntity[] findAll();
  ScalingPolicyEntity[] findByTenantId(TenantId tenantId);
  void save(ScalingPolicyEntity policy);
  void update(ScalingPolicyEntity policy);
  void remove(PolicyId id);
  size_t count();
}
