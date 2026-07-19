/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.backup_policies;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter;
import std.array  : array;
import std.conv   : to;

mixin(ShowModule!());

@safe:

class FileBackupPolicyRepository
    : TenantRepository!(BackupPolicy, BackupPolicyId)
    , BackupPolicyRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "backup_policies.json");
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
            BackupPolicy p;
            p.id          = BackupPolicyId(data.getString("id", ""));
            p.tenantId    = tenantId;
            p.instanceId  = ServiceInstanceId(data.getString("instanceId", ""));
            p.enabled     = data.getBoolean("enabled", false);
            p.intervalHours = data.getLong("intervalHours", 24);
            p.retentionDays = data.getLong("retentionDays", 7);
            p.lastBackupAt = data.getLong("lastBackupAt", 0);
            p.nextBackupAt = data.getLong("nextBackupAt", 0);
            p.status      = data.getString("status", "disabled").to!BackupStatus;
            p.backupLocation = data.getString("backupLocation", "");
            p.lastBackupId = data.getString("lastBackupId", "");
            p.lastError   = data.getString("lastError", "");
            p.createdAt   = data.getLong("createdAt", 0);
            super.save(p);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(BackupPolicy item)          { super.save(item); persistTenant(item.tenantId); }
    override void update(BackupPolicy item)        { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, BackupPolicyId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override BackupPolicy findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        auto results = findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
        return results.length > 0 ? results[0] : BackupPolicy.init;
    }

    override BackupPolicy[] findByStatus(TenantId tenantId, BackupStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }
}
