/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.usecases.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IManageScalingPoliciesUseCase {

  UsecaseResult createPolicy(CreateScalingPolicyRequest r);
  UsecaseResult updatePolicy(UpdateScalingPolicyRequest r);
  UsecaseResult deletePolicy(TenantId tenantId, ScalingPolicyId id);
  ScalingPolicyEntity getPolicy(TenantId tenantId, ScalingPolicyId id);
  ScalingPolicyEntity getPolicyByApp(TenantId tenantId, AppBindingId appId);
  ScalingPolicyEntity[] listPolicies(TenantId tenantId);

}
