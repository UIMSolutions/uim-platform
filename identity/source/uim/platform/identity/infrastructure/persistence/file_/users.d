/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File-based persistence for identity users.
module uim.platform.identity.infrastructure.persistence.file_.users;

import uim.platform.identity;
import std.file : exists, readText, write;
import std.json;

mixin(ShowModule!());

@safe:

class FileUserRepository : UserRepository {
    private string dataDir;
    private User[string] store;

    this(string dataDir) { this.dataDir = dataDir; loadFromFile(); }

    void save(User entity) { store[entity.id.value] = entity; persist(); }
    void update(User entity) { store[entity.id.value] = entity; persist(); }
    void remove(User entity) { store.remove(entity.id.value); persist(); }

    User findById(TenantId tenantId, UserId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return User.init;
    }
    User[] findByTenant(TenantId tenantId) {
        return store.values.filter!(u => u.tenantId == tenantId).array;
    }
    User findByUserName(TenantId tenantId, string userName) {
        foreach (u; findByTenant(tenantId)) if (u.userName == userName) return u;
        return User.init;
    }
    User findByEmail(TenantId tenantId, string email) {
        foreach (u; findByTenant(tenantId)) if (u.email == email) return u;
        return User.init;
    }
    User[] findByStatus(TenantId tenantId, UserStatus status) {
        return findByTenant(tenantId).filter!(u => u.status == status).array;
    }
    User[] findByType(TenantId tenantId, UserType type_) {
        return findByTenant(tenantId).filter!(u => u.type_ == type_).array;
    }
    User[] findByGroup(TenantId tenantId, GroupId groupId) {
        import std.algorithm : canFind;
        return findByTenant(tenantId).filter!(u => u.groups.canFind(groupId.value)).array;
    }

    private string filePath() { return dataDir ~ "/identity_users.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            import std.conv : to;
            auto jarr = parseJSON(readText(filePath())).array;
            foreach (j; jarr) {
                User u;
                u.id = UserId(j["id"].str);
                u.tenantId = TenantId(j["tenantId"].str);
                u.userName = j["userName"].str;
                u.email = j["email"].str;
                u.displayName = j.object.get("displayName", JSONValue("")).str;
                u.firstName = j.object.get("firstName", JSONValue("")).str;
                u.lastName = j.object.get("lastName", JSONValue("")).str;
                u.status = j["status"].str.to!UserStatus;
                u.type_ = j["type"].str.to!UserType;
                store[u.id.value] = u;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        import std.conv : to;
        JSONValue[] arr;
        foreach (u; store.values) {
            auto j = JSONValue(["id": JSONValue(u.id.value), "tenantId": JSONValue(u.tenantId.value),
                "userName": JSONValue(u.userName), "email": JSONValue(u.email),
                "displayName": JSONValue(u.displayName), "firstName": JSONValue(u.firstName),
                "lastName": JSONValue(u.lastName), "status": JSONValue(u.status.to!string),
                "type": JSONValue(u.type_.to!string)]);
            arr ~= j;
        }
        write(filePath(), JSONValue(arr).toString());
    }
}
