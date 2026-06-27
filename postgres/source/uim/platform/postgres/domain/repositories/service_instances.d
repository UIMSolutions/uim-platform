/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.repositories.service_instances;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

interface ServiceInstanceRepository : ITenantRepository!(ServiceInstance, ServiceInstanceId) {
    ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status);
    ServiceInstance[] findByPlan(TenantId tenantId, ServicePlanId planId);
    ServiceInstance[] findByHyperscaler(TenantId tenantId, Hyperscaler hyperscaler);
    bool nameExists(TenantId tenantId, string name);
}
