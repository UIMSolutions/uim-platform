/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.service_bindings;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter;
import std.array    : array;
import std.conv     : to;
import std.string   : lastIndexOf;

// mixin(ShowModule!());

@safe:

class FileServiceBindingRepository
    : TenantRepository!(ServiceBinding, ServiceBindingId)
    , ServiceBindingRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId t) {
        return buildPath(_basePath, t.value, "service_bindings.json");
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
            ServiceBinding e;
            e.id          = ServiceBindingId(data.getString("id", ""));
            e.tenantId    = t;
            e.instanceId  = ServiceInstanceId(data.getString("instanceId", ""));
            e.appId       = data.getString("appId", "");
            e.name        = data.getString("name", "");
            e.status      = data.getString("status", "active").to!BindingStatus;
            e.bindingHost = data.getString("bindingHost", "");
            e.bindingPort = cast(ushort) data.getLong("bindingPort", 5432);
            e.username    = data.getString("username", "");
            e.database    = data.getString("database", "");
            e.sslMode     = data.getString("sslMode", "require").to!SslMode;
            e.expiresAt   = data.getLong("expiresAt", 0);
            e.createdAt   = data.getLong("createdAt", 0);
            e.createdBy   = UserId(data.getString("createdBy", ""));
            e.updatedBy   = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId t) { super.createTenant(t); loadTenant(t); }
    override void save(ServiceBinding item)    { super.save(item); persistTenant(item.tenantId); }
    override void update(ServiceBinding item)  { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId t, ServiceBindingId id) { super.removeById(t, id); persistTenant(t); }

    override ServiceBinding[] findByInstance(TenantId t, ServiceInstanceId iid) {
        return findByTenant(t).filter!(e => e.instanceId == iid).array;
    }
    override ServiceBinding[] findByStatus(TenantId t, BindingStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override ServiceBinding findByInstanceAndApp(TenantId t, ServiceInstanceId iid, string appId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == iid && e.appId == appId).array;
        return r.length > 0 ? r[0] : ServiceBinding.init;
    }
}
