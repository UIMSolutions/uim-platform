/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.repositories.access_controls;

import uim.platform.redis;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class AccessControlRepository : TenantRepository!(AccessControl, AccessControlId), IAccessControlRepository {
    // #region ByInstance
    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }

    AccessControl[] filterByInstance(AccessControl[] records, ServiceInstanceId instanceId) {
        return records.filter!(s => s.instanceId == instanceId).array;
    }

    AccessControl[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return filterByInstance(findByTenant(tenantId), instanceId);
    }

    void removeByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        findByInstance(tenantId, instanceId).each!(entity => remove(entity));
    }
    // #endregion ByInstance

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, AccessControlStatus status) {
        return findByStatus(tenantId, status).length;
    }

    AccessControl[] filterByStatus(AccessControl[] records, AccessControlStatus status) {
        return records.filter!(s => s.status == status).array;
    }

    AccessControl[] findByStatus(TenantId tenantId, AccessControlStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, AccessControlStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }
    // #endregion ByStatus  

    bool cidrExists(TenantId tenantId, ServiceInstanceId instanceId, string cidr) {
        return findByTenant(tenantId).any!(e => e.instanceId == instanceId && e.cidr == cidr);
    }
}
