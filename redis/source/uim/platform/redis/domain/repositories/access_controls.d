/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.repositories.access_controls;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

interface AccessControlRepository : ITenantRepository!(AccessControl, AccessControlId) {
    AccessControl[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    AccessControl[] findByStatus(TenantId tenantId, AccessControlStatus status);
    bool cidrExists(TenantId tenantId, ServiceInstanceId instanceId, string cidr);
}
