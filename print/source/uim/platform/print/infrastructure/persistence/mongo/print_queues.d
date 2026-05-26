/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence for print queues using vibe.d's mongo driver.
module uim.platform.print.infrastructure.persistence.mongo.print_queues;

import uim.platform.print;
import vibe.db.mongo.mongo;
import vibe.data.bson;

mixin(ShowModule!());

@safe:

class MongoPrintQueueRepository : PrintQueueRepository {
    private MongoCollection coll;

    this(MongoCollection coll) {
        this.coll = coll;
    }

    void save(PrintQueue entity) @trusted {
        coll.insert(queueToBson(entity));
    }

    void update(PrintQueue entity) @trusted {
        coll.update(["_id": Bson(entity.id.value)], ["$set": queueToBson(entity)]);
    }

    void remove(PrintQueue entity) @trusted {
        coll.remove(["_id": Bson(entity.id.value)]);
    }

    PrintQueue findById(TenantId tenantId, PrintQueueId id) @trusted {
        auto doc = coll.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        if (doc.isNull) return PrintQueue.init;
        return bsonToQueue(doc);
    }

    PrintQueue[] findByTenant(TenantId tenantId) @trusted {
        PrintQueue[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value)]))
            result ~= bsonToQueue(doc);
        return result;
    }

    PrintQueue[] findByStatus(TenantId tenantId, PrintQueueStatus status) @trusted {
        import std.conv : to;
        PrintQueue[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
            result ~= bsonToQueue(doc);
        return result;
    }

    PrintQueue[] findByPrinter(TenantId tenantId, PrinterId printerId) @trusted {
        PrintQueue[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "printerId": Bson(printerId.value)]))
            result ~= bsonToQueue(doc);
        return result;
    }

    PrintQueue findDefault(TenantId tenantId) @trusted {
        auto doc = coll.findOne(["tenantId": Bson(tenantId.value), "isDefault": Bson(true)]);
        if (doc.isNull) return PrintQueue.init;
        return bsonToQueue(doc);
    }

    private static Bson queueToBson(const PrintQueue q) {
        import std.conv : to;
        auto b = Bson.emptyObject;
        b["_id"] = Bson(q.id.value);
        b["tenantId"] = Bson(q.tenantId.value);
        b["name"] = Bson(q.name);
        b["description"] = Bson(q.description);
        b["status"] = Bson(q.status.to!string);
        b["printerId"] = Bson(q.printerId.value);
        b["location"] = Bson(q.location);
        b["costCenter"] = Bson(q.costCenter);
        b["isDefault"] = Bson(q.isDefault);
        b["maxRetries"] = Bson(q.maxRetries);
        b["retentionDays"] = Bson(q.retentionDays);
        return b;
    }

    private static PrintQueue bsonToQueue(Bson b) {
        import std.conv : to;
        PrintQueue q;
        q.id = PrintQueueId(b["_id"].get!string);
        q.tenantId = TenantId(b["tenantId"].get!string);
        q.name = b["name"].get!string;
        q.description = b["description"].get!string;
        q.printerId = PrinterId(b["printerId"].get!string);
        q.location = b["location"].get!string;
        q.costCenter = b["costCenter"].get!string;
        q.isDefault = b["isDefault"].get!bool;
        q.maxRetries = b["maxRetries"].get!int;
        q.retentionDays = b["retentionDays"].get!int;
        q.status = b["status"].get!string.to!PrintQueueStatus;
        return q;
    }
}
