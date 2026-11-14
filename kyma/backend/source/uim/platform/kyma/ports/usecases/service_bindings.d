/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.service_bindings;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Service binding lifecycle.
interface IManageServiceBindingsUseCase : IManageResource!(ServiceBinding, ServiceBindingId,
    CreateServiceBindingRequest, UpdateServiceBindingRequest) {
}
