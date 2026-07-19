/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File-based persistence for printers.
module uim.platform.print.infrastructure.persistence.file_.printers;

import uim.platform.print;
import std.file : exists, readText, write;
import std.json;
mixin(ShowModule!());

@safe:

class FilePrinterRepository : PrinterRepository {
    private string dataDir;
    private Printer[string] store;

    this(string dataDir) {
        this.dataDir = dataDir;
        loadFromFile();
    }

    void save(Printer entity) { store[entity.id.value] = entity; persist(); }
    void update(Printer entity) { store[entity.id.value] = entity; persist(); }
    void remove(Printer entity) { store.remove(entity.id.value); persist(); }

    Printer findById(TenantId tenantId, PrinterId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return Printer.init;
    }

    Printer[] findByTenant(TenantId tenantId) {
        return store.values.filter!(p => p.tenantId == tenantId).array;
    }

    Printer[] findByStatus(TenantId tenantId, PrinterStatus status) {
        return findByTenant(tenantId).filter!(p => p.status == status).array;
    }

    Printer[] findByClient(TenantId tenantId, PrintClientId clientId) {
        return findByTenant(tenantId).filter!(p => p.clientId == clientId).array;
    }

    Printer[] findByProtocol(TenantId tenantId, PrinterProtocol protocol) {
        return findByTenant(tenantId).filter!(p => p.protocol == protocol).array;
    }

    private string filePath() { return dataDir ~ "/printers.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            
            foreach (j; parseJSON(readText(filePath())).array) {
                Printer p;
                p.id = PrinterId(j["id"].str);
                p.tenantId = TenantId(j["tenantId"].str);
                p.name = j["name"].str;
                p.host = j["host"].str;
                p.port = cast(ushort) j["port"].integer;
                p.status = j["status"].str.to!PrinterStatus;
                p.protocol = j["protocol"].str.to!PrinterProtocol;
                store[p.id.value] = p;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        
        Json arr = Json(cast(Json) []);
        foreach (p; store.values) {
            Json j;
            j["id"] = p.id.value;
            j["tenantId"] = p.tenantId.value;
            j["name"] = p.name;
            j["host"] = p.host;
            j["port"] = cast(int) p.port;
            j["status"] = p.status.to!string;
            j["protocol"] = p.protocol.to!string;
            arr.array ~= j;
        }
        write(filePath(), arr.toPrettyString());
    }
}
