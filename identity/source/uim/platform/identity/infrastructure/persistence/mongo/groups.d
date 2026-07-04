/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.mongo.groups;

import uim.platform.identity;
import vibe.db.mongo.mongo;

mixin(ShowModule!());

@safe:

// class MongoGroupRepository : GroupRepository {
//     private MongoCollection collection;

//     this(MongoCollection col) { this.collection = col; }

//     void save(IDMGroup entity) @trusted { collection.insert(entityToBson(entity)); }
//     void update(IDMGroup entity) @trusted {
//         collection.update(["_id": Bson(entity.id.value)], ["$set": entityToBson(entity)]);
//     }
//     void remove(IDMGroup entity) @trusted { collection.remove(["_id": Bson(entity.id.value)]); }

//     IDMGroup findById(TenantId tenantId, IDMGroupId id) @trusted {
//         auto doc = collection.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
//         return doc.isNull ? IDMGroup.init : bsonToEntity(doc);
//     }
//     IDMGroup[] findByTenant(TenantId tenantId) @trusted {
//         IDMGroup[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToEntity(doc);
//         return result;
//     }
//     IDMGroup findByName(TenantId tenantId, string name) @trusted {
//         auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "name": Bson(name)]);
//         return doc.isNull ? IDMGroup.init : bsonToEntity(doc);
//     }
//     IDMGroup[] findByType(TenantId tenantId, GroupType type_) @trusted {
        
//         IDMGroup[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "type": Bson(type_.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }
//     IDMGroup[] findByMember(TenantId tenantId, UserId userId) @trusted {
//         IDMGroup[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "members": Bson(userId.value)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }

//     private static Bson entityToBson(IDMGroup g) @trusted {
        
//         Bson[] members;
//         foreach (m; g.memberIds) members ~= Bson(m);
//         return Bson(["_id": Bson(g.id.value), "tenantId": Bson(g.tenantId.value),
//             "name": Bson(g.name), "description": Bson(g.description),
//             "type": Bson(g.type_.to!string), "members": Bson(members)]);
//     }

//     private static IDMGroup bsonToEntity(Bson doc) @trusted {
        
//         IDMGroup g;
//         g.id = IDMGroupId(doc["_id"].get!string);
//         g.tenantId = TenantId(doc["tenantId"].get!string);
//         g.name = doc["name"].get!string;
//         g.description = doc.tryIndex("description").isNull ? "" : doc["description"].get!string;
//         g.type_ = doc["type"].get!string.to!GroupType;
//         if (!doc.tryIndex("members").isNull)
//             foreach (m; doc["members"].get!(Bson[])) g.memberIds ~= m.get!string;
//         return g;
//     }
// }
