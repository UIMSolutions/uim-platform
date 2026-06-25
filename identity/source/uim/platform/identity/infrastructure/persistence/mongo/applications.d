/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.mongo.applications;

import uim.platform.identity;
import vibe.db.mongo.mongo;

// mixin(ShowModule!());

@safe:

// class MongoApplicationRepository : ApplicationRepository {
//     private MongoCollection collection;

//     this(MongoCollection col) { this.collection = col; }

//     void save(Application entity) @trusted { collection.insert(entityToBson(entity)); }
//     void update(Application entity) @trusted {
//         collection.update(["_id": Bson(entity.id.value)], ["$set": entityToBson(entity)]);
//     }
//     void remove(Application entity) @trusted { collection.remove(["_id": Bson(entity.id.value)]); }

//     Application findById(TenantId tenantId, ApplicationId id) @trusted {
//         auto doc = collection.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
//         return doc.isNull ? Application.init : bsonToEntity(doc);
//     }
//     Application[] findByTenant(TenantId tenantId) @trusted {
//         Application[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToEntity(doc);
//         return result;
//     }
//     Application findByClient(TenantId tenantId, string clientId) @trusted {
//         auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "clientId": Bson(clientId)]);
//         return doc.isNull ? Application.init : bsonToEntity(doc);
//     }
//     Application[] findByStatus(TenantId tenantId, AppStatus status) @trusted {
        
//         Application[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }
//     Application[] findByProtocol(TenantId tenantId, AppProtocol protocol) @trusted {
        
//         Application[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "protocol": Bson(protocol.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }

//     private static Bson entityToBson(Application a) @trusted {
        
//         return Bson(["_id": Bson(a.id.value), "tenantId": Bson(a.tenantId.value),
//             "name": Bson(a.name), "clientId": Bson(a.clientId),
//             "protocol": Bson(a.protocol.to!string), "status": Bson(a.status.to!string)]);
//     }

//     private static Application bsonToEntity(Bson doc) @trusted {
        
//         Application a;
//         a.id = ApplicationId(doc["_id"].get!string);
//         a.tenantId = TenantId(doc["tenantId"].get!string);
//         a.name = doc["name"].get!string;
//         a.clientId = doc["clientId"].get!string;
//         a.protocol = doc["protocol"].get!string.to!AppProtocol;
//         a.status = doc["status"].get!string.to!AppStatus;
//         return a;
//     }
// }
