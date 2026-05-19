/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.service_instance;

import uim.platform.redis;

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
    RedisVersion redisVersion;
    long memoryMb;
    long maxConnections;
    string host;
    ushort port;
    bool tlsEnabled;
    bool haEnabled;
    PersistenceMode persistenceMode;
    string connectionString; // not in detailed toJson for security
    long provisionedAt;
    long updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id",              id.value)
            .set("tenantId",        tenantId.value)
            .set("name",            name)
            .set("description",     description)
            .set("planId",          planId.value)
            .set("status",          status.to!string)
            .set("hyperscaler",     hyperscaler.to!string)
            .set("region",          region)
            .set("redisVersion",    redisVersion.to!string)
            .set("memoryMb",        memoryMb)
            .set("maxConnections",  maxConnections)
            .set("host",            host)
            .set("port",            cast(long) port)
            .set("tlsEnabled",      tlsEnabled)
            .set("haEnabled",       haEnabled)
            .set("persistenceMode", persistenceMode.to!string)
            .set("provisionedAt",   provisionedAt)
            .set("updatedAt",       updatedAt)
            .set("createdAt",       createdAt)
            .set("createdBy",       createdBy.value)
            .set("updatedBy",       updatedBy.value);
    }
}
