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

  CommandResult createBinding(CreateAppBindingRequest r);
  CommandResult updateBinding(UpdateAppBindingRequest r);
  CommandResult deleteBinding(TenantId tenantId, AppBindingId id);
  CommandResult attachPolicy(TenantId tenantId, AppBindingId bindingId, ScalingPolicyId policyId);
  
}
