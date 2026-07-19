/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.service_binding;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

struct ServiceBinding {
    mixin TenantEntity!(ServiceBindingId);

    ServiceInstanceId instanceId;
    string appId;
    string name;
    BindingStatus status;
    string bindingHost;
    ushort bindingPort;
    string username;
    string database;
    SslMode sslMode;
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
            .set("username",    username)
            .set("database",    database)
            .set("sslMode",     sslMode.to!string)
            .set("expiresAt",   expiresAt)
            .set("createdAt",   createdAt)
            .set("createdBy",   createdBy.value)
            .set("updatedBy",   updatedBy.value);
    }
}
