/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.tls_configurations;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryTlsConfigurationRepository : TlsConfigurationRepository {
    private TlsConfiguration[] store;

    TlsConfiguration findById(TlsConfigurationId id) {
        foreach (c; store) {
            if (c.id == id)
                return c;
        }
        return TlsConfiguration.init;
    }

    TlsConfiguration[] findByTenant(TenantId tenantId) {
        return store.filter!(c => c.tenantId == tenantId).array;
    }

    void save(TlsConfiguration c) {
        store ~= c;
    }

    void update(TlsConfiguration c) {
        foreach (existing; store) {
            if (existing.id == c.id) {
                existing = c;
                return;
            }
        }
    }

    void remove(TlsConfigurationId id) {
        store = store.filter!(c => c.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(c => c.tenantId == tenantId).array.length;
    }
}
