/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.file_.applications;

import uim.platform.identity;
import std.file : exists, readText, write;
import std.json;

// mixin(ShowModule!());

@safe:

class FileApplicationRepository : ApplicationRepository {
    private string dataDir;
    private Application[string] store;

    this(string dataDir) { this.dataDir = dataDir; loadFromFile(); }

    void save(Application entity) { store[entity.id.value] = entity; persist(); }
    void update(Application entity) { store[entity.id.value] = entity; persist(); }
    void remove(Application entity) { store.remove(entity.id.value); persist(); }

    Application findById(TenantId tenantId, ApplicationId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return Application.init;
    }
    Application[] findByTenant(TenantId tenantId) {
        return store.values.filter!(a => a.tenantId == tenantId).array;
    }
    Application findByClient(TenantId tenantId, string clientId) {
        foreach (a; findByTenant(tenantId)) if (a.clientId == clientId) return a;
        return Application.init;
    }
    Application[] findByStatus(TenantId tenantId, AppStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }
    Application[] findByProtocol(TenantId tenantId, AppProtocol protocol) {
        return findByTenant(tenantId).filter!(a => a.protocol == protocol).array;
    }

    private string filePath() { return dataDir ~ "/identity_applications.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            
            foreach (j; parseJSON(readText(filePath())).array) {
                Application a;
                a.id = ApplicationId(j["id"].str);
                a.tenantId = TenantId(j["tenantId"].str);
                a.name = j["name"].str;
                a.clientId = j["clientId"].str;
                a.protocol = j["protocol"].str.to!AppProtocol;
                a.status = j["status"].str.to!AppStatus;
                store[a.id.value] = a;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        
        JSONValue[] arr;
        foreach (a; store.values) {
            arr ~= JSONValue(["id": JSONValue(a.id.value), "tenantId": JSONValue(a.tenantId.value),
                "name": JSONValue(a.name), "clientId": JSONValue(a.clientId),
                "protocol": JSONValue(a.protocol.to!string), "status": JSONValue(a.status.to!string)]);
        }
        write(filePath(), JSONValue(arr).toString());
    }
}
