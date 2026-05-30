/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.file_.groups;

import uim.platform.identity;
import std.file : exists, readText, write;
import std.json;

mixin(ShowModule!());

@safe:

class FileGroupRepository : GroupRepository {
    private string dataDir;
    private Group[string] store;

    this(string dataDir) { this.dataDir = dataDir; loadFromFile(); }

    void save(Group entity) { store[entity.id.value] = entity; persist(); }
    void update(Group entity) { store[entity.id.value] = entity; persist(); }
    void remove(Group entity) { store.remove(entity.id.value); persist(); }

    Group findById(TenantId tenantId, GroupId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return Group.init;
    }
    Group[] findByTenant(TenantId tenantId) {
        return store.values.filter!(g => g.tenantId == tenantId).array;
    }
    Group findByName(TenantId tenantId, string name) {
        foreach (g; findByTenant(tenantId)) if (g.name == name) return g;
        return Group.init;
    }
    Group[] findByType(TenantId tenantId, GroupType type_) {
        return findByTenant(tenantId).filter!(g => g.type_ == type_).array;
    }
    Group[] findByMember(TenantId tenantId, UserId userId) {
        import std.algorithm : canFind;
        return findByTenant(tenantId).filter!(g => g.memberIds.canFind(userId.value)).array;
    }

    private string filePath() { return dataDir ~ "/identity_groups.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            
            foreach (j; parseJSON(readText(filePath())).array) {
                Group g;
                g.id = GroupId(j["id"].str);
                g.tenantId = TenantId(j["tenantId"].str);
                g.name = j["name"].str;
                g.description = j.object.get("description", JSONValue("")).str;
                g.type_ = j["type"].str.to!GroupType;
                foreach (m; j.object.get("members", JSONValue(cast(JSONValue[])[])).array)
                    g.memberIds ~= m.str;
                store[g.id.value] = g;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        
        JSONValue[] arr;
        foreach (g; store.values) {
            JSONValue[] members;
            foreach (m; g.memberIds) members ~= JSONValue(m);
            auto j = JSONValue(["id": JSONValue(g.id.value), "tenantId": JSONValue(g.tenantId.value),
                "name": JSONValue(g.name), "description": JSONValue(g.description),
                "type": JSONValue(g.type_.to!string), "members": JSONValue(members)]);
            arr ~= j;
        }
        write(filePath(), JSONValue(arr).toString());
    }
}
