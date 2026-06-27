/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.service_bindings;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter, any;
import std.array  : array;
import std.conv   : to;

// mixin(ShowModule!());

@safe:

class FileServiceBindingRepository
    : TentRepository!(ServiceBinding, ServiceBindingId)
    , ServiceBindingRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "service_bindings.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        auto items = findByTenant(tenantId);
        Json arr = Json.emptyArray;
        foreach (i; items) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        if (!exists(path)) return;
        auto arr = parseJson(readText(path));
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            ServiceBinding b;
            b.id         = ServiceBindingId(data.getString("id", ""));
            b.tenantId   = tenantId;
            b.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
            b.appId      = data.getString("appId", "");
            b.name       = data.getString("name", "");
            b.status     = data.getString("status", "active").to!BindingStatus;
            b.bindingHost = data.getString("bindingHost", "");
            b.bindingPort = cast(ushort) data.getLong("bindingPort", 6379);
            b.expiresAt  = data.getLong("expiresAt", 0);
            b.createdAt  = data.getLong("createdAt", 0);
            super.save(b);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(ServiceBinding item)        { super.save(item); persistTenant(item.tenantId); }
    override void update(ServiceBinding item)      { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, ServiceBindingId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override ServiceBinding[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override ServiceBinding findByInstanceAndApp(TenantId tenantId, ServiceInstanceId instanceId, string appId) {
        auto results = findByTenant(tenantId).filter!(e => e.instanceId == instanceId && e.appId == appId).array;
        return results.length > 0 ? results[0] : ServiceBinding.init;
    }
}
