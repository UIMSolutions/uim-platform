/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.usecases.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Service bindings of a dev space. `connect` queues a connection test (connecting).
interface IManageServiceBindingsUseCase : IManageResource!(ServiceBinding, ServiceBindingId,
    CreateServiceBindingRequest, UpdateServiceBindingRequest) {
  UsecaseResult connect(TenantId tenantId, ServiceBindingId id, UserId actor);
  UsecaseResult disconnect(TenantId tenantId, ServiceBindingId id, UserId actor);
}
