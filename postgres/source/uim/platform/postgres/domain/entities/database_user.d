/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.database_user;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

struct DatabaseUser {
    mixin TenantEntity!(DatabaseUserId);

    ServiceInstanceId instanceId;
    string username;
    string roles;       // comma-separated: "readonly,readwrite"
    UserStatus status;

    Json toJson() const {
        return Json.emptyObject
            .set("id",         id.value)
            .set("tenantId",   tenantId.value)
            .set("instanceId", instanceId.value)
            .set("username",   username)
            .set("roles",      roles)
            .set("status",     status.to!string)
            .set("createdAt",  createdAt)
            .set("createdBy",  createdBy.value)
            .set("updatedBy",  updatedBy.value);
    }
}
