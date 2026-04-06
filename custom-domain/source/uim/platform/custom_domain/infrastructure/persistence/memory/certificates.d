/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryCertificateRepository : CertificateRepository {
    private Certificate[] store;

    Certificate findById(CertificateId id) {
        foreach (ref c; store) {
            if (c.id == id)
                return c;
        }
        return Certificate.init;
    }

    Certificate[] findByTenant(TenantId tenantId) {
        return store.filter!(c => c.tenantId == tenantId).array;
    }

    Certificate[] findByKey(PrivateKeyId keyId) {
        return store.filter!(c => c.keyId == keyId).array;
    }

    Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp) {
        return store.filter!(c => c.tenantId == tenantId && c.validTo > 0 && c.validTo <= beforeTimestamp).array;
    }

    void save(Certificate c) {
        store ~= c;
    }

    void update(Certificate c) {
        foreach (ref existing; store) {
            if (existing.id == c.id) {
                existing = c;
                return;
            }
        }
    }

    void remove(CertificateId id) {
        store = store.filter!(c => c.id != id).array;
    }

    long countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(c => c.tenantId == tenantId).array.length;
    }
}
