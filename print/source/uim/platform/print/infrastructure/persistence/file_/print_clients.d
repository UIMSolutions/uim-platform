/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File-based persistence for print clients.
module uim.platform.print.infrastructure.persistence.file_.print_clients;

import uim.platform.print;
import std.file : exists, readText, write;
import std.json;
mixin(ShowModule!());

@safe:

class FilePrintClientRepository : PrintClientRepository {
    private string dataDir;
    private PrintClient[string] store;

    this(string dataDir) {
        this.dataDir = dataDir;
        loadFromFile();
    }

    void save(PrintClient entity) { store[entity.id.value] = entity; persist(); }
    void update(PrintClient entity) { store[entity.id.value] = entity; persist(); }
    void remove(PrintClient entity) { store.remove(entity.id.value); persist(); }

    PrintClient findById(TenantId tenantId, PrintClientId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return PrintClient.init;
    }

    PrintClient[] findByTenant(TenantId tenantId) {
        return store.values.filter!(c => c.tenantId == tenantId).array;
    }

    PrintClient[] findByStatus(TenantId tenantId, PrintClientStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    PrintClient findByToken(TenantId tenantId, string authToken) {
        auto matches = findByTenant(tenantId).filter!(c => c.authToken == authToken).array;
        return matches.length > 0 ? matches[0] : PrintClient.init;
    }

    private string filePath() { return dataDir ~ "/print_clients.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            
            foreach (j; parseJSON(readText(filePath())).array) {
                PrintClient c;
                c.id = PrintClientId(j["id"].str);
                c.tenantId = TenantId(j["tenantId"].str);
                c.name = j["name"].str;
                c.hostName = j["hostName"].str;
                c.ipAddress = j["ipAddress"].str;
                c.authToken = j["authToken"].str;
                c.status = j["status"].str.to!PrintClientStatus;
                store[c.id.value] = c;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        
        Json arr = Json(cast(Json) []);
        foreach (c; store.values) {
            Json j;
            j["id"] = c.id.value;
            j["tenantId"] = c.tenantId.value;
            j["name"] = c.name;
            j["hostName"] = c.hostName;
            j["ipAddress"] = c.ipAddress;
            j["authToken"] = c.authToken;
            j["status"] = c.status.to!string;
            arr.array ~= j;
        }
        write(filePath(), arr.toPrettyString());
    }
}
