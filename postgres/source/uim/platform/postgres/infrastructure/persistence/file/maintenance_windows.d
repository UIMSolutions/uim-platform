/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.maintenance_windows;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter;
import std.array    : array;
import std.conv     : to;
import std.string   : lastIndexOf;

mixin(ShowModule!());

@safe:

class FileMaintenanceWindowRepository
    : TenantRepository!(MaintenanceWindow, MaintenanceWindowId)
    , MaintenanceWindowRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId t) {
        return buildPath(_basePath, t.value, "maintenance_windows.json");
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
            MaintenanceWindow e;
            e.id                      = MaintenanceWindowId(data.getString("id", ""));
            e.tenantId                = t;
            e.instanceId              = ServiceInstanceId(data.getString("instanceId", ""));
            e.dayOfWeek               = data.getString("dayOfWeek", "Sunday");
            e.startHourUtc            = j.getLong("startHourUtc", 2);
            e.durationHours           = j.getLong("durationHours", 1);
            e.autoMinorVersionUpgrade = j.getBoolean("autoMinorVersionUpgrade", true);
            e.status                  = data.getString("status", "scheduled").to!MaintenanceStatus;
            e.lastMaintenanceAt       = j.getLong("lastMaintenanceAt", 0);
            e.nextMaintenanceAt       = j.getLong("nextMaintenanceAt", 0);
            e.createdAt               = j.getLong("createdAt", 0);
            e.createdBy               = UserId(data.getString("createdBy", ""));
            e.updatedBy               = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId t) { super.createTenant(t); loadTenant(t); }
    override void save(MaintenanceWindow item)   { super.save(item); persistTenant(item.tenantId); }
    override void update(MaintenanceWindow item) { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId t, MaintenanceWindowId id) { super.removeById(t, id); persistTenant(t); }

    override MaintenanceWindow findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : MaintenanceWindow.init;
    }
    override MaintenanceWindow[] findByStatus(TenantId t, MaintenanceStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
}
