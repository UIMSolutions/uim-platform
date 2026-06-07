/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.mongo.identity_providers;

import uim.platform.identity;
import vibe.db.mongo.mongo;

// mixin(ShowModule!());

@safe:

class MongoIdentityProviderRepository : IdentityProviderRepository {
    private MongoCollection collection;

    this(MongoCollection col) { this.collection = col; }

    void save(IdentityProvider entity) @trusted { collection.insert(entityToBson(entity)); }
    void update(IdentityProvider entity) @trusted {
        collection.update(["_id": Bson(entity.id.value)], ["$set": entityToBson(entity)]);
    }
    void remove(IdentityProvider entity) @trusted { collection.remove(["_id": Bson(entity.id.value)]); }

    IdentityProvider findById(TenantId tenantId, IdentityProviderId id) @trusted {
        auto doc = collection.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        return doc.isNull ? IdentityProvider.init : bsonToEntity(doc);
    }
    IdentityProvider[] findByTenant(TenantId tenantId) @trusted {
        IdentityProvider[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToEntity(doc);
        return result;
    }
    IdentityProvider findByEntityId(TenantId tenantId, string entityId) @trusted {
        auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "entityId": Bson(entityId)]);
        return doc.isNull ? IdentityProvider.init : bsonToEntity(doc);
    }
    IdentityProvider findDefault(TenantId tenantId) @trusted {
        auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "isDefault": Bson(true)]);
        return doc.isNull ? IdentityProvider.init : bsonToEntity(doc);
    }
    IdentityProvider[] findByStatus(TenantId tenantId, IdpStatus status) @trusted {
        
        IdentityProvider[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
            result ~= bsonToEntity(doc);
        return result;
    }
    IdentityProvider[] findByType(TenantId tenantId, IdpType type_) @trusted {
        
        IdentityProvider[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "type": Bson(type_.to!string)]))
            result ~= bsonToEntity(doc);
        return result;
    }

    private static Bson entityToBson(IdentityProvider idp) @trusted {
        
        return Bson(["_id": Bson(idp.id.value), "tenantId": Bson(idp.tenantId.value),
            "name": Bson(idp.name), "entityId": Bson(idp.entityId),
            "type": Bson(idp.type_.to!string), "status": Bson(idp.status.to!string),
            "isDefault": Bson(idp.isDefault)]);
    }

    private static IdentityProvider bsonToEntity(Bson doc) @trusted {
        
        IdentityProvider idp;
        idp.id = IdentityProviderId(doc["_id"].get!string);
        idp.tenantId = TenantId(doc["tenantId"].get!string);
        idp.name = doc["name"].get!string;
        idp.entityId = doc.tryIndex("entityId").isNull ? "" : doc["entityId"].get!string;
        idp.type_ = doc["type"].get!string.to!IdpType;
        idp.status = doc["status"].get!string.to!IdpStatus;
        idp.isDefault = doc.tryIndex("isDefault").isNull ? false : doc["isDefault"].get!bool;
        return idp;
    }
}
