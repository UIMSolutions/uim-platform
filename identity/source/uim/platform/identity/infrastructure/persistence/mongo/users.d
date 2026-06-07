/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence adapter for identity users.
module uim.platform.identity.infrastructure.persistence.mongo.users;

import uim.platform.identity;
import vibe.db.mongo.mongo;

// mixin(ShowModule!());

@safe:

class MongoUserRepository : UserRepository {
    private MongoCollection collection;

    this(MongoCollection col) { this.collection = col; }

    void save(User entity) @trusted { collection.insert(entityToBson(entity)); }
    void update(User entity) @trusted {
        collection.update(["_id": Bson(entity.id.value)], ["$set": entityToBson(entity)]);
    }
    void remove(User entity) @trusted { collection.remove(["_id": Bson(entity.id.value)]); }

    User findById(TenantId tenantId, UserId id) @trusted {
        auto doc = collection.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        return doc.isNull ? User.init : bsonToEntity(doc);
    }
    User[] findByTenant(TenantId tenantId) @trusted {
        User[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToEntity(doc);
        return result;
    }
    User findByUserName(TenantId tenantId, string userName) @trusted {
        auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "userName": Bson(userName)]);
        return doc.isNull ? User.init : bsonToEntity(doc);
    }
    User findByEmail(TenantId tenantId, string email) @trusted {
        auto doc = collection.findOne(["tenantId": Bson(tenantId.value), "email": Bson(email)]);
        return doc.isNull ? User.init : bsonToEntity(doc);
    }
    User[] findByStatus(TenantId tenantId, UserStatus status) @trusted {
        
        User[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
            result ~= bsonToEntity(doc);
        return result;
    }
    User[] findByType(TenantId tenantId, UserType type_) @trusted {
        
        User[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "type": Bson(type_.to!string)]))
            result ~= bsonToEntity(doc);
        return result;
    }
    User[] findByGroup(TenantId tenantId, GroupId groupId) @trusted {
        User[] result;
        foreach (doc; collection.find(["tenantId": Bson(tenantId.value), "groups": Bson(groupId.value)]))
            result ~= bsonToEntity(doc);
        return result;
    }

    private static Bson entityToBson(User u) @trusted {
        
        return Bson(["_id": Bson(u.id.value), "tenantId": Bson(u.tenantId.value),
            "userName": Bson(u.userName), "email": Bson(u.email),
            "displayName": Bson(u.displayName), "firstName": Bson(u.firstName),
            "lastName": Bson(u.lastName), "status": Bson(u.status.to!string),
            "type": Bson(u.type_.to!string)]);
    }

    private static User bsonToEntity(Bson doc) @trusted {
        
        User u;
        u.id = UserId(doc["_id"].get!string);
        u.tenantId = TenantId(doc["tenantId"].get!string);
        u.userName = doc["userName"].get!string;
        u.email = doc["email"].get!string;
        u.displayName = doc.tryIndex("displayName").isNull ? "" : doc["displayName"].get!string;
        u.firstName = doc.tryIndex("firstName").isNull ? "" : doc["firstName"].get!string;
        u.lastName = doc.tryIndex("lastName").isNull ? "" : doc["lastName"].get!string;
        u.status = doc["status"].get!string.to!UserStatus;
        u.type_ = doc["type"].get!string.to!UserType;
        return u;
    }
}
