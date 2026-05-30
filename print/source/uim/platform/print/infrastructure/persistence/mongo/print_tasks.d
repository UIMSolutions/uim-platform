/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence for print tasks.
module uim.platform.print.infrastructure.persistence.mongo.print_tasks;

import uim.platform.print;
import vibe.db.mongo.mongo;
import vibe.data.bson;

mixin(ShowModule!());

@safe:

class MongoPrintTaskRepository : PrintTaskRepository {
    private MongoCollection coll;

    this(MongoCollection coll) {
        this.coll = coll;
    }

    void save(PrintTask entity) @trusted { coll.insert(taskToBson(entity)); }
    void update(PrintTask entity) @trusted { coll.update(["_id": Bson(entity.id.value)], ["$set": taskToBson(entity)]); }
    void remove(PrintTask entity) @trusted { coll.remove(["_id": Bson(entity.id.value)]); }

    PrintTask findById(TenantId tenantId, PrintTaskId id) @trusted {
        auto doc = coll.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        if (doc.isNull) return PrintTask.init;
        return bsonToTask(doc);
    }

    PrintTask[] findByTenant(TenantId tenantId) @trusted {
        PrintTask[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToTask(doc);
        return result;
    }

    PrintTask[] findByQueue(TenantId tenantId, PrintQueueId queueId) @trusted {
        PrintTask[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "queueId": Bson(queueId.value)]))
            result ~= bsonToTask(doc);
        return result;
    }

    PrintTask[] findByStatus(TenantId tenantId, PrintTaskStatus status) @trusted {
        
        PrintTask[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
            result ~= bsonToTask(doc);
        return result;
    }

    PrintTask[] findPendingByQueue(TenantId tenantId, PrintQueueId queueId) @trusted {
        PrintTask[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "queueId": Bson(queueId.value), "status": Bson("pending")]))
            result ~= bsonToTask(doc);
        return result;
    }

    size_t countByStatus(TenantId tenantId, PrintTaskStatus status) {
        return findByStatus(tenantId, status).length;
    }

    private static Bson taskToBson(const PrintTask t) {
        
        auto b = Bson.emptyObject;
        b["_id"] = Bson(t.id.value);
        b["tenantId"] = Bson(t.tenantId.value);
        b["queueId"] = Bson(t.queueId.value);
        b["documentId"] = Bson(t.documentId.value);
        b["applicationId"] = Bson(t.applicationId);
        b["senderApplication"] = Bson(t.senderApplication);
        b["copies"] = Bson(t.copies);
        b["status"] = Bson(t.status.to!string);
        b["errorMessage"] = Bson(t.errorMessage);
        b["retryCount"] = Bson(t.retryCount);
        return b;
    }

    private static PrintTask bsonToTask(Bson b) {
        
        PrintTask t;
        t.id = PrintTaskId(b["_id"].get!string);
        t.tenantId = TenantId(b["tenantId"].get!string);
        t.queueId = PrintQueueId(b["queueId"].get!string);
        t.documentId = PrintDocumentId(b["documentId"].get!string);
        t.applicationId = b["applicationId"].get!string;
        t.senderApplication = b["senderApplication"].get!string;
        t.copies = b["copies"].get!int;
        t.status = b["status"].get!string.to!PrintTaskStatus;
        t.errorMessage = b["errorMessage"].get!string;
        t.retryCount = b["retryCount"].get!int;
        return t;
    }
}
