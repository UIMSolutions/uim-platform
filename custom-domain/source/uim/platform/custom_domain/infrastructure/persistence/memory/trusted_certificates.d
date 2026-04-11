/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.trusted_certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryTrustedCertificateRepository : TrustedCertificateRepository {
    private TrustedCertificate[] store;

    TrustedCertificate findById(TrustedCertificateId id) {
        foreach (c; store) {
            if (c.id == id)
                return c;
        }
        return TrustedCertificate.init;
    }

    TrustedCertificate[] findByTenant(TenantId tenantId) {
        return store.filter!(c => c.tenantId == tenantId).array;
    }

    TrustedCertificate[] findByDomain(CustomDomainId domainId) {
        return store.filter!(c => c.customDomainId == domainId).array;
    }

    void save(TrustedCertificate c) {
        store ~= c;
    }

    void update(TrustedCertificate c) {
        foreach (existing; store) {
            if (existing.id == c.id) {
                existing = c;
                return;
            }
        }
    }

    void remove(TrustedCertificateId id) {
        store = store.filter!(c => c.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(c => c.tenantId == tenantId).array.length;
    }
}
