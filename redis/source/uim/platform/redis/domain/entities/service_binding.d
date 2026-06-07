/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.service_binding;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

struct ServiceBinding {
    mixin TenantEntity!(ServiceBindingId);

    ServiceInstanceId instanceId;
    string appId;
    string name;
    BindingStatus status;
    string bindingHost;
    ushort bindingPort;
    string password;        // NOT in toJson
    string tlsCertificate;  // NOT in toJson
    string redisUrl;        // NOT in toJson
    long expiresAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id",          id.value)
            .set("tenantId",    tenantId.value)
            .set("instanceId",  instanceId.value)
            .set("appId",       appId)
            .set("name",        name)
            .set("status",      status.to!string)
            .set("bindingHost", bindingHost)
            .set("bindingPort", cast(long) bindingPort)
            .set("expiresAt",   expiresAt)
            .set("createdAt",   createdAt)
            .set("createdBy",   createdBy.value)
            .set("updatedBy",   updatedBy.value);
    }
}
