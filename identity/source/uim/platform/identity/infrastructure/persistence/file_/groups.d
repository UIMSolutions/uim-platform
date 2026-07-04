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

// class FileGroupRepository : GroupRepository {
//     private string dataDir;
//     private IDMGroup[string] store;

//     this(string dataDir) { this.dataDir = dataDir; loadFromFile(); }

//     void save(IDMGroup entity) { store[entity.id.value] = entity; persist(); }
//     void update(IDMGroup entity) { store[entity.id.value] = entity; persist(); }
//     void remove(IDMGroup entity) { store.remove(entity.id.value); persist(); }

//     IDMGroup findById(TenantId tenantId, IDMGroupId id) {
//         if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
//         return IDMGroup.init;
//     }
//     IDMGroup[] findByTenant(TenantId tenantId) {
//         return store.values.filter!(g => g.tenantId == tenantId).array;
//     }
//     IDMGroup findByName(TenantId tenantId, string name) {
//         foreach (g; findByTenant(tenantId)) if (g.name == name) return g;
//         return IDMGroup.init;
//     }
//     IDMGroup[] findByType(TenantId tenantId, GroupType type_) {
//         return findByTenant(tenantId).filter!(g => g.type_ == type_).array;
//     }
//     IDMGroup[] findByMember(TenantId tenantId, UserId userId) {
//         import std.algorithm : canFind;
//         return findByTenant(tenantId).filter!(g => g.memberIds.canFind(userId.value)).array;
//     }

//     private string filePath() { return dataDir ~ "/identity_groups.json"; }

//     private void loadFromFile() @trusted {
//         if (!filePath().exists) return;
//         try {
            
//             foreach (j; parseJSON(readText(filePath())).array) {
//                 IDMGroup g;
//                 g.id = IDMGroupId(j["id"].str);
//                 g.tenantId = TenantId(j["tenantId"].str);
//                 g.name = j["name"].str;
//                 g.description = j.object.get("description", Json("")).str;
//                 g.type_ = j["type"].str.to!GroupType;
//                 foreach (m; j.object.get("members", Json(cast(Json)[])).array)
//                     g.memberIds ~= m.str;
//                 store[g.id.value] = g;
//             }
//         } catch (Exception) {}
//     }

//     private void persist() @trusted {
        
//         Json arr;
//         foreach (g; store.values) {
//             Json members;
//             foreach (m; g.memberIds) members ~= Json(m);
//             auto j = Json(["id": Json(g.id.value), "tenantId": Json(g.tenantId.value),
//                 "name": Json(g.name), "description": Json(g.description),
//                 "type": Json(g.type_.to!string), "members": Json(members)]);
//             arr ~= j;
//         }
//         write(filePath(), Json(arr).toString());
//     }
// }
