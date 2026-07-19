/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.service_instance;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

struct ServiceInstance {
    mixin TenantEntity!(ServiceInstanceId);

    string name;
    string description;
    ServicePlanId planId;
    InstanceStatus status;
    Hyperscaler hyperscaler;
    string region;
    PostgresVersion engineVersion;
    long memoryGb;
    long storageGb;
    string host;
    ushort port;
    string dbName;
    bool sslEnabled;
    bool multiAz;
    long provisionedAt;
    long updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id",            id.value)
            .set("tenantId",      tenantId.value)
            .set("name",          name)
            .set("description",   description)
            .set("planId",        planId.value)
            .set("status",        status.to!string)
            .set("hyperscaler",   hyperscaler.to!string)
            .set("region",        region)
            .set("engineVersion", engineVersion.to!string)
            .set("memoryGb",      memoryGb)
            .set("storageGb",     storageGb)
            .set("host",          host)
            .set("port",          cast(long) port)
            .set("dbName",        dbName)
            .set("sslEnabled",    sslEnabled)
            .set("multiAz",       multiAz)
            .set("provisionedAt", provisionedAt)
            .set("updatedAt",     updatedAt)
            .set("createdAt",     createdAt)
            .set("createdBy",     createdBy.value)
            .set("updatedBy",     updatedBy.value);
    }
}
