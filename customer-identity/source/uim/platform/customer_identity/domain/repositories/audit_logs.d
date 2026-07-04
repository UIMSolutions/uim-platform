/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.audit_logs;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

interface AuditLogRepository : ITenantRepository!(AuditLog, AuditLogId) {
    AuditLog[] findByActor(TenantId tenantId, string actorId);
    AuditLog[] findByAction(TenantId tenantId, AuditAction action);
    AuditLog[] findByResource(TenantId tenantId, ResourceType resourceType, string resourceId);
    AuditLog[] findByTimeRange(TenantId tenantId, long fromTimestamp, long toTimestamp);
}
