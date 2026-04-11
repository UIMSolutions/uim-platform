/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.private_keys;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryPrivateKeyRepository : PrivateKeyRepository {
    private PrivateKey[] store;

    PrivateKey findById(PrivateKeyId id) {
        foreach (k; store) {
            if (k.id == id)
                return k;
        }
        return PrivateKey.init;
    }

    PrivateKey[] findByTenant(TenantId tenantId) {
        return store.filter!(k => k.tenantId == tenantId).array;
    }

    void save(PrivateKey k) {
        store ~= k;
    }

    void update(PrivateKey k) {
        foreach (existing; store) {
            if (existing.id == k.id) {
                existing = k;
                return;
            }
        }
    }

    void remove(PrivateKeyId id) {
        store = store.filter!(k => k.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(k => k.tenantId == tenantId).array.length;
    }
}
