/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.access_control;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

struct AccessControl {
    mixin TenantEntity!(AccessControlId);

    ServiceInstanceId instanceId;
    string cidr;
    string description;
    AccessControlStatus status;

    Json toJson() const {
        return Json.emptyObject
            .set("id",          id.value)
            .set("tenantId",    tenantId.value)
            .set("instanceId",  instanceId.value)
            .set("cidr",        cidr)
            .set("description", description)
            .set("status",      status.to!string)
            .set("createdAt",   createdAt)
            .set("createdBy",   createdBy.value)
            .set("updatedBy",   updatedBy.value);
    }
}
