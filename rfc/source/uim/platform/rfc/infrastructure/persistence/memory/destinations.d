/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.persistence.memory.destinations;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

class MemoryDestinationRepository : DestinationRepository {

    private Destination[string] _store;

    private static string _key(TenantId tenantId, DestinationId id) {
        return tenantId ~ "|" ~ id;
    }

    override Destination findById(TenantId tenantId, DestinationId id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return Destination.init;
        auto d = _store[key];
        return d;
    }

    override Destination[] findByTenant(TenantId tenantId) {
        Destination[] result;
        foreach (kv; _store.byKeyValue()) {
            if (kv.value.tenantId == tenantId) {
                result ~= Destination(kv.value.id, kv.value.tenantId, kv.value.connectionType,
                    kv.value.description, kv.value.host, kv.value.port, kv.value.systemId,
                    kv.value.systemNumber, kv.value.client, kv.value.language,
                    kv.value.logonUser, kv.value.useSNC, kv.value.active,
                    kv.value.createdAt, kv.value.updatedAt);
            }
        }
        return result;
    }

    override bool save(Destination dest) {
        auto key = _key(dest.tenantId, dest.id);
        if (key in _store) return false;
        _store[key] = dest;
        return true;
    }

    override bool update(Destination dest) {
        auto key = _key(dest.tenantId, dest.id);
        if (key !in _store) return false;
        _store[key] = dest;
        return true;
    }

    override bool remove(TenantId tenantId, DestinationId id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return false;
        _store.remove(key);
        return true;
    }

    override size_t countByTenant(TenantId tenantId) {
        size_t n = 0;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId) n++;
        return n;
    }
}
