/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.configurations;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter;
import std.array  : array;
import std.conv   : to;

mixin(ShowModule!());

@safe:

class FileConfigurationRepository
    : TenantRepository!(Configuration, ConfigurationId)
    , ConfigurationRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "configurations.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        Json arr = Json.emptyArray;
        foreach (i; findByTenant(tenantId)) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        if (!exists(path)) return;
        auto arr = parseJson(readText(path));
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            Configuration c;
            c.id              = ConfigurationId(data.getString("id", ""));
            c.tenantId        = tenantId;
            c.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
            c.maxMemoryPolicy = data.getString("maxMemoryPolicy", "allkeys-lru").to!MaxMemoryPolicy;
            c.timeout         = data.getLong("timeout", 0);
            c.maxConnections  = data.getLong("maxConnections", 10000);
            c.tlsEnabled      = data.getBoolean("tlsEnabled", true);
            c.persistenceMode = data.getString("persistenceMode", "none").to!PersistenceMode;
            c.maxMemoryMb     = data.getLong("maxMemoryMb", 256);
            c.notifyKeyspaceEvents = data.getBoolean("notifyKeyspaceEvents", false);
            c.activeVersion   = data.getString("activeVersion", "");
            c.createdAt       = data.getLong("createdAt", 0);
            super.save(c);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(Configuration item)         { super.save(item); persistTenant(item.tenantId); }
    override void update(Configuration item)       { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, ConfigurationId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override Configuration findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        auto results = findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
        return results.length > 0 ? results[0] : Configuration.init;
    }
}
