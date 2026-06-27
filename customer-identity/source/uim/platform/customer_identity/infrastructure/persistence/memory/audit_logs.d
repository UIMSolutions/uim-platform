/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.memory.audit_logs;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class MemoryAuditLogRepository : TenantRepository!(AuditLog, AuditLogId), AuditLogRepository {

    AuditLog[] findByActor(TenantId tenantId, string actorId) {
        return findByTenant(tenantId).filter!(al => al.actorId == actorId).array;
    }

    AuditLog[] findByAction(TenantId tenantId, AuditAction action) {
        return findByTenant(tenantId).filter!(al => al.action == action).array;
    }

    AuditLog[] findByResource(TenantId tenantId, ResourceType resourceType, string resourceId) {
        return findByTenant(tenantId)
            .filter!(al => al.resourceType == resourceType && al.resourceId == resourceId).array;
    }

    AuditLog[] findByTimeRange(TenantId tenantId, long fromTimestamp, long toTimestamp) {
        return findByTenant(tenantId)
            .filter!(al => al.timestamp >= fromTimestamp && al.timestamp <= toTimestamp).array;
    }
}
