/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.database_users;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter, any;
import std.array    : array;
import std.conv     : to;
import std.string   : lastIndexOf;

// mixin(ShowModule!());

@safe:

class FileDatabaseUserRepository
    : TenantRepository!(DatabaseUser, DatabaseUserId)
    , DatabaseUserRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId t) {
        return buildPath(_basePath, t.value, "database_users.json");
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
            DatabaseUser e;
            e.id         = DatabaseUserId(data.getString("id", ""));
            e.tenantId   = t;
            e.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
            e.username   = data.getString("username", "");
            e.roles      = data.getString("roles", "readonly");
            e.status     = data.getString("status", "active").to!UserStatus;
            e.createdAt  = data.getLong("createdAt", 0);
            e.createdBy  = UserId(data.getString("createdBy", ""));
            e.updatedBy  = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId t) { super.createTenant(t); loadTenant(t); }
    override void save(DatabaseUser item)   { super.save(item); persistTenant(item.tenantId); }
    override void update(DatabaseUser item) { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId t, DatabaseUserId id) { super.removeById(t, id); persistTenant(t); }

    override DatabaseUser[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
        return findByTenant(t).filter!(e => e.instanceId == instanceId).array;
    }
    override DatabaseUser[] findByStatus(TenantId t, UserStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override bool usernameExists(TenantId t, ServiceInstanceId instanceId, string username) {
        return findByTenant(t).any!(e => e.instanceId == instanceId && e.username == username);
    }
}
