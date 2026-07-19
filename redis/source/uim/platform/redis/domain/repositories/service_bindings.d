/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.repositories.service_bindings;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {
    ServiceBinding[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status);
    ServiceBinding findByInstanceAndApp(TenantId tenantId, ServiceInstanceId instanceId, string appId);
}
