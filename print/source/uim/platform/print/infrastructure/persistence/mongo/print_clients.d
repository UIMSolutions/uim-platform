/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence for print clients.
module uim.platform.print.infrastructure.persistence.mongo.print_clients;

import uim.platform.print;
import vibe.db.mongo.mongo;
import vibe.data.bson;

mixin(ShowModule!());

@safe:

class MongoPrintClientRepository : PrintClientRepository {
    private MongoCollection coll;

    this(MongoCollection coll) {
        this.coll = coll;
    }

    void save(PrintClient entity) @trusted { coll.insert(clientToBson(entity)); }
    void update(PrintClient entity) @trusted { coll.update(["_id": Bson(entity.id.value)], ["$set": clientToBson(entity)]); }
    void remove(PrintClient entity) @trusted { coll.remove(["_id": Bson(entity.id.value)]); }

    PrintClient findById(TenantId tenantId, PrintClientId id) @trusted {
        auto doc = coll.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        if (doc.isNull) return PrintClient.init;
        return bsonToClient(doc);
    }

    PrintClient[] findByTenant(TenantId tenantId) @trusted {
        PrintClient[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToClient(doc);
        return result;
    }

    PrintClient[] findByStatus(TenantId tenantId, PrintClientStatus status) @trusted {
        
        PrintClient[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
            result ~= bsonToClient(doc);
        return result;
    }

    PrintClient findByToken(TenantId tenantId, string authToken) @trusted {
        auto doc = coll.findOne(["tenantId": Bson(tenantId.value), "authToken": Bson(authToken)]);
        if (doc.isNull) return PrintClient.init;
        return bsonToClient(doc);
    }

    private static Bson clientToBson(const PrintClient c) {
        
        auto b = Bson.emptyObject;
        b["_id"] = Bson(c.id.value);
        b["tenantId"] = Bson(c.tenantId.value);
        b["name"] = Bson(c.name);
        b["description"] = Bson(c.description);
        b["hostName"] = Bson(c.hostName);
        b["ipAddress"] = Bson(c.ipAddress);
        b["osType"] = Bson(c.osType);
        b["osVersion"] = Bson(c.osVersion);
        b["authToken"] = Bson(c.authToken);
        b["status"] = Bson(c.status.to!string);
        b["lastSeenAt"] = Bson(c.lastSeenAt);
        return b;
    }

    private static PrintClient bsonToClient(Bson b) {
        
        PrintClient c;
        c.id = PrintClientId(b["_id"].get!string);
        c.tenantId = TenantId(b["tenantId"].get!string);
        c.name = b["name"].get!string;
        c.hostName = b["hostName"].get!string;
        c.ipAddress = b["ipAddress"].get!string;
        c.authToken = b["authToken"].get!string;
        c.status = b["status"].get!string.to!PrintClientStatus;
        c.lastSeenAt = b["lastSeenAt"].get!long;
        return c;
    }
}
