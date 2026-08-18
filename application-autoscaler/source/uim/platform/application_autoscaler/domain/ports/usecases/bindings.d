/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.usecases.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IManageAppBindingsUseCase {

  UsecaseResult createBinding(CreateAppBindingRequest r);
  UsecaseResult updateBinding(UpdateAppBindingRequest r);
  UsecaseResult deleteBinding(TenantId tenantId, AppBindingId id);
  UsecaseResult attachPolicy(TenantId tenantId, AppBindingId bindingId, ScalingPolicyId policyId);
  
}
