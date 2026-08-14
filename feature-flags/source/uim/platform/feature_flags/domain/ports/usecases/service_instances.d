/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.ports.usecases.service_instances;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

interface IManageServiceInstancesUseCase {

    ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id);

    ServiceInstance[] listInstances(TenantId tenantId);

    FlagResult createInstance(CreateServiceInstanceRequest req);

    FlagResult updateInstance(TenantId tenantId, ServiceInstanceId id, UpdateServiceInstanceRequest req);

    FlagResult deleteInstance(TenantId tenantId, ServiceInstanceId id, string deletedBy = "");

}
