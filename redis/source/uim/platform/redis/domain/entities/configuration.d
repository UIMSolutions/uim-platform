/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.configuration;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

struct Configuration {
    mixin TenantEntity!(ConfigurationId);

    ServiceInstanceId instanceId;
    MaxMemoryPolicy maxMemoryPolicy;
    long timeout;
    long maxConnections;
    bool tlsEnabled;
    PersistenceMode persistenceMode;
    long maxMemoryMb;
    bool notifyKeyspaceEvents;
    string activeVersion;

    Json toJson() const {
        return Json.emptyObject
            .set("id",                      id.value)
            .set("tenantId",                tenantId.value)
            .set("instanceId",              instanceId.value)
            .set("maxMemoryPolicy",         maxMemoryPolicy.to!string)
            .set("timeout",                 timeout)
            .set("maxConnections",          maxConnections)
            .set("tlsEnabled",              tlsEnabled)
            .set("persistenceMode",         persistenceMode.to!string)
            .set("maxMemoryMb",             maxMemoryMb)
            .set("notifyKeyspaceEvents",    notifyKeyspaceEvents)
            .set("activeVersion",           activeVersion)
            .set("createdAt",               createdAt)
            .set("createdBy",               createdBy.value)
            .set("updatedBy",               updatedBy.value);
    }
}
