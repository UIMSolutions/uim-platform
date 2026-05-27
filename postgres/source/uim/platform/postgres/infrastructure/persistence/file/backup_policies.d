/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.backup_policies;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter;
import std.array    : array;
import std.conv     : to;
import std.string   : lastIndexOf;

mixin(ShowModule!());

@safe:

class FileBackupPolicyRepository
    : TenantRepository!(BackupPolicy, BackupPolicyId)
    , BackupPolicyRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId t) {
        return buildPath(_basePath, t.value, "backup_policies.json");
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
            BackupPolicy e;
            e.id              = BackupPolicyId(data.getString("id", ""));
            e.tenantId        = t;
            e.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
            e.retentionPeriod = data.getLong("retentionPeriod", 7);
            e.backupWindow    = data.getString("backupWindow", "");
            e.lastBackupAt    = data.getLong("lastBackupAt", 0);
            e.nextBackupAt    = data.getLong("nextBackupAt", 0);
            e.status          = data.getString("status", "enabled").to!BackupStatus;
            e.backupLocation  = data.getString("backupLocation", "");
            e.lastError       = data.getString("lastError", "");
            e.createdAt       = data.getLong("createdAt", 0);
            e.createdBy       = UserId(data.getString("createdBy", ""));
            e.updatedBy       = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId t) { super.createTenant(t); loadTenant(t); }
    override void save(BackupPolicy item)   { super.save(item); persistTenant(item.tenantId); }
    override void update(BackupPolicy item) { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId t, BackupPolicyId id) { super.removeById(t, id); persistTenant(t); }

    override BackupPolicy findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : BackupPolicy.init;
    }
    override BackupPolicy[] findByStatus(TenantId t, BackupStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
}
