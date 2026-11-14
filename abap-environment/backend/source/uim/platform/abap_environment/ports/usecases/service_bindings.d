/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.service_bindings;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// RAP service bindings: create (unpublished), publish, unpublish, deprecate.
interface IManageServiceBindingsUseCase : IManageResource!(ServiceBinding, ServiceBindingId,
    CreateServiceBindingRequest, UpdateServiceBindingRequest) {
  UsecaseResult publish(TenantId tenantId, ServiceBindingId id, UserId actor);
  UsecaseResult unpublish(TenantId tenantId, ServiceBindingId id, UserId actor);
  UsecaseResult deprecate(TenantId tenantId, ServiceBindingId id, UserId actor);
}
