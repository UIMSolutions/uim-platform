/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.file_.identity_providers;

import uim.platform.identity;
import std.file : exists, readText, write;
import std.json;

// mixin(ShowModule!());

@safe:

class FileIdentityProviderRepository : IdentityProviderRepository {
    private string dataDir;
    private IdentityProvider[string] store;

    this(string dataDir) { this.dataDir = dataDir; loadFromFile(); }

    void save(IdentityProvider entity) { store[entity.id.value] = entity; persist(); }
    void update(IdentityProvider entity) { store[entity.id.value] = entity; persist(); }
    void remove(IdentityProvider entity) { store.remove(entity.id.value); persist(); }

    IdentityProvider findById(TenantId tenantId, IdentityProviderId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return IdentityProvider.init;
    }
    IdentityProvider[] findByTenant(TenantId tenantId) {
        return store.values.filter!(idp => idp.tenantId == tenantId).array;
    }
    IdentityProvider findByEntityId(TenantId tenantId, string entityId) {
        foreach (idp; findByTenant(tenantId)) if (idp.entityId == entityId) return idp;
        return IdentityProvider.init;
    }
    IdentityProvider findDefault(TenantId tenantId) {
        foreach (idp; findByTenant(tenantId)) if (idp.isDefault) return idp;
        return IdentityProvider.init;
    }
    IdentityProvider[] findByStatus(TenantId tenantId, IdpStatus status) {
        return findByTenant(tenantId).filter!(idp => idp.status == status).array;
    }
    IdentityProvider[] findByType(TenantId tenantId, IdpType type_) {
        return findByTenant(tenantId).filter!(idp => idp.type_ == type_).array;
    }

    private string filePath() { return dataDir ~ "/identity_providers.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            
            foreach (j; parseJSON(readText(filePath())).array) {
                IdentityProvider idp;
                idp.id = IdentityProviderId(j["id"].str);
                idp.tenantId = TenantId(j["tenantId"].str);
                idp.name = j["name"].str;
                idp.entityId = j.object.get("entityId", Json("")).str;
                idp.type_ = j["type"].str.to!IdpType;
                idp.status = j["status"].str.to!IdpStatus;
                idp.isDefault = j.object.get("isDefault", Json(false)).boolean;
                store[idp.id.value] = idp;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        
        Json arr;
        foreach (idp; store.values) {
            arr ~= Json(["id": Json(idp.id.value), "tenantId": Json(idp.tenantId.value),
                "name": Json(idp.name), "entityId": Json(idp.entityId),
                "type": Json(idp.type_.to!string), "status": Json(idp.status.to!string),
                "isDefault": Json(idp.isDefault)]);
        }
        write(filePath(), Json(arr).toString());
    }
}
