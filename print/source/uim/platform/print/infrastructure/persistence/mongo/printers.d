/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB persistence for printers.
module uim.platform.print.infrastructure.persistence.mongo.printers;

import uim.platform.print;
import vibe.db.mongo.mongo;
import vibe.data.bson;
mixin(ShowModule!());

@safe:

class MongoPrinterRepository : PrinterRepository {
    private MongoCollection coll;

    this(MongoCollection coll) {
        this.coll = coll;
    }

    void save(Printer entity) @trusted { coll.insert(printerToBson(entity)); }
    void update(Printer entity) @trusted { coll.update(["_id": Bson(entity.id.value)], ["$set": printerToBson(entity)]); }
    void remove(Printer entity) @trusted { coll.remove(["_id": Bson(entity.id.value)]); }

    Printer findById(TenantId tenantId, PrinterId id) @trusted {
        auto doc = coll.findOne(["_id": Bson(id.value), "tenantId": Bson(tenantId.value)]);
        if (doc.isNull) return Printer.init;
        return bsonToPrinter(doc);
    }

    Printer[] findByTenant(TenantId tenantId) @trusted {
        Printer[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value)])) result ~= bsonToPrinter(doc);
        return result;
    }

    Printer[] findByStatus(TenantId tenantId, PrinterStatus status) @trusted {
        
        Printer[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "status": Bson(status.to!string)]))
            result ~= bsonToPrinter(doc);
        return result;
    }

    Printer[] findByClient(TenantId tenantId, PrintClientId clientId) @trusted {
        Printer[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "clientId": Bson(clientId.value)]))
            result ~= bsonToPrinter(doc);
        return result;
    }

    Printer[] findByProtocol(TenantId tenantId, PrinterProtocol protocol) @trusted {
        
        Printer[] result;
        foreach (doc; coll.find(["tenantId": Bson(tenantId.value), "protocol": Bson(protocol.to!string)]))
            result ~= bsonToPrinter(doc);
        return result;
    }

    private static Bson printerToBson(const Printer p) {
        
        auto b = Bson.emptyObject;
        b["_id"] = Bson(p.id.value);
        b["tenantId"] = Bson(p.tenantId.value);
        b["name"] = Bson(p.name);
        b["description"] = Bson(p.description);
        b["host"] = Bson(p.host);
        b["port"] = Bson(cast(int) p.port);
        b["queue"] = Bson(p.queue);
        b["location"] = Bson(p.location);
        b["model"] = Bson(p.model);
        b["vendor"] = Bson(p.vendor);
        b["colorCapable"] = Bson(p.colorCapable);
        b["duplexCapable"] = Bson(p.duplexCapable);
        b["clientId"] = Bson(p.clientId.value);
        b["status"] = Bson(p.status.to!string);
        b["protocol"] = Bson(p.protocol.to!string);
        return b;
    }

    private static Printer bsonToPrinter(Bson b) {
        
        Printer p;
        p.id = PrinterId(b["_id"].get!string);
        p.tenantId = TenantId(b["tenantId"].get!string);
        p.name = b["name"].get!string;
        p.host = b["host"].get!string;
        p.port = cast(ushort) b["port"].get!int;
        p.queue = b["queue"].get!string;
        p.location = b["location"].get!string;
        p.clientId = PrintClientId(b["clientId"].get!string);
        p.status = b["status"].get!string.to!PrinterStatus;
        p.protocol = b["protocol"].get!string.to!PrinterProtocol;
        return p;
    }
}
