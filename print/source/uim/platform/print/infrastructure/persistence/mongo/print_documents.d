/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence for print documents.
module uim.platform.print.infrastructure.persistence.mongo.print_documents;

import uim.platform.print;
import vibe.db.mongo.mongo;
import vibe.data.bson;

// mixin(ShowModule!());

@safe:

class MongoPrintDocumentRepository : PrintDocumentRepository {
    private MongoCollection coll;

    this(MongoCollection coll) {
        this.coll = coll;
    }

    void save(PrintDocument entity) @trusted { coll.insert(docToBson(entity)); }
    void update(PrintDocument entity) @trusted { coll.update(["_id": Bson(entity.id.value)], ["$set": docToBson(entity)]); }
    void remove(PrintDocument entity) @trusted { coll.remove(["_id": Bson(entity.id.value)]); }

    PrintDocument findById(TenantId tenantId, PrintDocumentId id) @trusted {
        auto doc = coll.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        if (doc.isNull) return PrintDocument.init;
        return bsonToDoc(doc);
    }

    PrintDocument[] findByTenant(TenantId tenantId) @trusted {
        PrintDocument[] result;
        foreach (d; coll.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToDoc(d);
        return result;
    }

    PrintDocument[] findByFormat(TenantId tenantId, DocumentFormat format) @trusted {
        
        PrintDocument[] result;
        foreach (d; coll.find(["tenantId": Bson(tenantId.value), "format": Bson(format.to!string)]))
            result ~= bsonToDoc(d);
        return result;
    }

    PrintDocument[] findExpired(TenantId tenantId, long nowTimestamp) {
        return findByTenant(tenantId)
            .filter!(d => d.expiresAt > 0 && d.expiresAt < nowTimestamp).array;
    }

    void removeExpired(TenantId tenantId, long nowTimestamp) {
        findExpired(tenantId, nowTimestamp).each!(d => remove(d));
    }

    private static Bson docToBson(const PrintDocument d) {
        
        auto b = Bson.emptyObject;
        b["_id"] = Bson(d.id.value);
        b["tenantId"] = Bson(d.tenantId.value);
        b["fileName"] = Bson(d.fileName);
        b["mimeType"] = Bson(d.mimeType);
        b["format"] = Bson(d.format.to!string);
        b["sizeBytes"] = Bson(d.sizeBytes);
        b["storageUri"] = Bson(d.storageUri);
        b["checksum"] = Bson(d.checksum);
        b["expiresAt"] = Bson(d.expiresAt);
        return b;
    }

    private static PrintDocument bsonToDoc(Bson b) {
        
        PrintDocument d;
        d.id = PrintDocumentId(b["_id"].get!string);
        d.tenantId = TenantId(b["tenantId"].get!string);
        d.fileName = b["fileName"].get!string;
        d.mimeType = b["mimeType"].get!string;
        d.format = b["format"].get!string.to!DocumentFormat;
        d.sizeBytes = b["sizeBytes"].get!long;
        d.storageUri = b["storageUri"].get!string;
        d.checksum = b["checksum"].get!string;
        d.expiresAt = b["expiresAt"].get!long;
        return d;
    }
}
