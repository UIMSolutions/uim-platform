/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.access_controls;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter, any;
import std.array  : array;
import std.conv   : to;
mixin(ShowModule!());

@safe:

class FileAccessControlRepository
    : TenantRepository!(AccessControl, AccessControlId)
    , AccessControlRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "access_controls.json");
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
            AccessControl a;
            a.id          = AccessControlId(data.getString("id", ""));
            a.tenantId    = tenantId;
            a.instanceId  = ServiceInstanceId(data.getString("instanceId", ""));
            a.cidr        = data.getString("cidr", "");
            a.description = data.getString("description", "");
            a.status      = data.getString("status", "active").to!AccessControlStatus;
            a.createdAt   = data.getLong("createdAt", 0);
            super.save(a);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(AccessControl item)         { super.save(item); persistTenant(item.tenantId); }
    override void update(AccessControl item)       { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, AccessControlId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override AccessControl[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override AccessControl[] findByStatus(TenantId tenantId, AccessControlStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override bool cidrExists(TenantId tenantId, ServiceInstanceId instanceId, string cidr) {
        return findByTenant(tenantId).any!(e => e.instanceId == instanceId && e.cidr == cidr);
    }
}
