/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.audit_log;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct AuditLog {
    mixin TenantEntity!(AuditLogId);

    string actorId;
    AuditAction action;
    ResourceType resourceType;
    string resourceId;
    string ipAddress;
    string userAgent;
    long timestamp;
    string details;
    bool success;

    Json toJson() const {
        return entityToJson
            .set("actorId", actorId)
            .set("action", action.to!string)
            .set("resourceType", resourceType.to!string)
            .set("resourceId", resourceId)
            .set("ipAddress", ipAddress)
            .set("userAgent", userAgent)
            .set("timestamp", timestamp)
            .set("details", details)
            .set("success", success);
    }
}
