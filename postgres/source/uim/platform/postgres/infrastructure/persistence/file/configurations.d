/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.configurations;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter;
import std.array    : array;
import std.string   : lastIndexOf;

mixin(ShowModule!());

@safe:

class FileConfigurationRepository
    : TenantRepository!(Configuration, ConfigurationId)
    , ConfigurationRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId t) {
        return buildPath(_basePath, t.value, "configurations.json");
    }

    private void persistTenant(TenantId t) @trusted {
        auto path = filePath(t);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        Json arr = Json.emptyArray;
        foreach (i; findByTenant(t)) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId t) @trusted {
        auto path = filePath(t);
        if (!exists(path)) return;
        auto arr = parseJson(readText(path));
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            Configuration e;
            e.id                       = ConfigurationId(data.getString("id", ""));
            e.tenantId                 = t;
            e.instanceId               = ServiceInstanceId(data.getString("instanceId", ""));
            e.auditLogLevels           = data.getString("auditLogLevels", "");
            e.backupRetentionPeriod    = data.getLong("backupRetentionPeriod", 7);
            e.locale                   = data.getString("locale", "en_US");
            e.maxConnections           = data.getLong("maxConnections", 100);
            e.workMem                  = data.getLong("workMem", 4096);
            e.sharedBuffersMb          = data.getLong("sharedBuffersMb", 128);
            e.maintenanceWindowDay     = data.getString("maintenanceWindowDay", "");
            e.maintenanceWindowStartHour = data.getLong("maintenanceWindowStartHour", 0);
            e.maintenanceWindowDuration  = data.getLong("maintenanceWindowDuration", 1);
            e.activeVersion            = data.getString("activeVersion", "");
            e.createdAt                = data.getLong("createdAt", 0);
            e.createdBy                = UserId(data.getString("createdBy", ""));
            e.updatedBy                = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId t) { super.createTenant(t); loadTenant(t); }
    override void save(Configuration item)    { super.save(item); persistTenant(item.tenantId); }
    override void update(Configuration item)  { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId t, ConfigurationId id) { super.removeById(t, id); persistTenant(t); }

    override Configuration findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : Configuration.init;
    }
}
