/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.mongo.provisioning_jobs;

import uim.platform.identity;
import vibe.db.mongo.mongo;

mixin(ShowModule!());

@safe:

// class MongoProvisioningJobRepository : ProvisioningJobRepository {
//     private MongoCollection collection;

//     this(MongoCollection col) { this.collection = col; }

//     void save(ProvisioningJob entity) @trusted { collection.insert(entityToBson(entity)); }
//     void update(ProvisioningJob entity) @trusted {
//         collection.update(["_id": Bson(entity.id.value)], ["$set": entityToBson(entity)]);
//     }
//     void remove(ProvisioningJob entity) @trusted { collection.remove(["_id": Bson(entity.id.value)]); }

//     ProvisioningJob findById(TenantId tenantId, ProvisioningJobId id) @trusted {
//         auto doc = collection.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
//         return doc.isNull ? ProvisioningJob.init : bsonToEntity(doc);
//     }
//     ProvisioningJob[] findByTenant(TenantId tenantId) @trusted {
//         ProvisioningJob[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToEntity(doc);
//         return result;
//     }
//     ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status) @trusted {
        
//         ProvisioningJob[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }
//     ProvisioningJob[] findByType(TenantId tenantId, JobType type_) @trusted {
        
//         ProvisioningJob[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "type": Bson(type_.to!string)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }
//     ProvisioningJob[] findByTargetSystem(TenantId tenantId, string targetSystem) @trusted {
//         ProvisioningJob[] result;
//         foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "targetSystem": Bson(targetSystem)]))
//             result ~= bsonToEntity(doc);
//         return result;
//     }

//     private static Bson entityToBson(ProvisioningJob j) @trusted {
        
//         return Bson(["_id": Bson(j.id.value), "tenantId": Bson(j.tenantId.value),
//             "name": Bson(j.name), "sourceSystem": Bson(j.sourceSystem),
//             "targetSystem": Bson(j.targetSystem), "type": Bson(j.type_.to!string),
//             "status": Bson(j.status.to!string)]);
//     }

//     private static ProvisioningJob bsonToEntity(Bson doc) @trusted {
        
//         ProvisioningJob j;
//         j.id = ProvisioningJobId(doc["_id"].get!string);
//         j.tenantId = TenantId(doc["tenantId"].get!string);
//         j.name = doc["name"].get!string;
//         j.sourceSystem = doc["sourceSystem"].get!string;
//         j.targetSystem = doc["targetSystem"].get!string;
//         j.type_ = doc["type"].get!string.to!JobType;
//         j.status = doc["status"].get!string.to!JobStatus;
//         return j;
//     }
// }
