/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.service_instances;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// BTP service instance lifecycle (requires the btp-operator module).
interface IManageServiceInstancesUseCase : IManageResource!(ServiceInstance, ServiceInstanceId,
    CreateServiceInstanceRequest, UpdateServiceInstanceRequest) {
}
