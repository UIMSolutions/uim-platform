/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.service_account;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct ServiceAccount {
    ServiceAccountId id;
    TenantId tenantId;
    string name;
    string description;
    ServiceAccountStatus status = ServiceAccountStatus.active;
    string clientId;
    string permissions;
    string lastUsedAt;
    string expiresAt;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;

    Json serviceAccountToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("clientId", clientId)
            .set("permissions", permissions)
            .set("lastUsedAt", lastUsedAt)
            .set("expiresAt", expiresAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}
