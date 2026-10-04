/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence adapter for identity users.
module uim.platform.identity.infrastructure.persistence.mongo.users;

import uim.platform.identity;
import vibe.db.mongo.mongo;

mixin(ShowModule!());

@safe:

// class MongoUserRepository : UserRepository {
//     private MongoCollection collection;

//     this(MongoCollection col) { this.collection = col; }

//     void save(IdmUser entity) @trusted { collection.insert(entityToBson(entity)); }
//     void update(IdmUser entity) @trusted {
//         collection.update(["_id": Bson(entity.id.value)], ["$set": entityToBson(entity)]);
//     }
//     void remove(IdmUser entity) @trusted { collection.remove(["_id": Bson(entity.id.value)]); }

//     IdmUser findById(TenantId tenantId, UserId id) @trusted {
//         auto doc = collection.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
//         return doc.isNull ? IdmUser.init : bsonToEntity(doc);
//     }
//     IdmUser[] findByTenant(TenantId tenantId) @trusted {
//         IdmUser[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToEntity(doc);
//         return result;
//     }
//     IdmUser findByUserName(TenantId tenantId, string userName) @trusted {
//         auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "userName": Bson(userName)]);
//         return doc.isNull ? IdmUser.init : bsonToEntity(doc);
//     }
//     IdmUser findByEmail(TenantId tenantId, string email) @trusted {
//         auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "email": Bson(email)]);
//         return doc.isNull ? IdmUser.init : bsonToEntity(doc);
//     }
//     IdmUser[] findByStatus(TenantId tenantId, UserStatus status) @trusted {
        
//         IdmUser[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }
//     IdmUser[] findByType(TenantId tenantId, UserType type_) @trusted {
        
//         IdmUser[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "type": Bson(type_.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }
//     IdmUser[] findByGroup(TenantId tenantId, IDMGroupId groupId) @trusted {
//         IdmUser[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "groups": Bson(groupId.value)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }

//     private static Bson entityToBson(IdmUser u) @trusted {
        
//         return Bson(["_id": Bson(u.id.value), "tenantId": Bson(u.tenantId.value),
//             "userName": Bson(u.userName), "email": Bson(u.email),
//             "displayName": Bson(u.displayName), "firstName": Bson(u.firstName),
//             "lastName": Bson(u.lastName), "status": Bson(u.status.to!string),
//             "type": Bson(u.type_.to!string)]);
//     }

//     private static IdmUser bsonToEntity(Bson doc) @trusted {
        
//         IdmUser u;
//         u.id = UserId(doc["_id"].get!string);
//         u.tenantId = TenantId(doc["tenantId"].get!string);
//         u.userName = doc["userName"].get!string;
//         u.email = doc["email"].get!string;
//         u.displayName = doc.tryIndex("displayName").isNull ? "" : doc["displayName"].get!string;
//         u.firstName = doc.tryIndex("firstName").isNull ? "" : doc["firstName"].get!string;
//         u.lastName = doc.tryIndex("lastName").isNull ? "" : doc["lastName"].get!string;
//         u.status = doc["status"].get!string.to!UserStatus;
//         u.type_ = doc["type"].get!string.to!UserType;
//         return u;
//     }
// }
