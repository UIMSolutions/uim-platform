/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.domain_mappings;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDomainMappingRepository : DomainMappingRepository {
    private DomainMapping[] store;

    DomainMapping findById(DomainMappingId id) {
        foreach (m; store) {
            if (m.id == id)
                return m;
        }
        return DomainMapping.init;
    }

    DomainMapping[] findByTenant(TenantId tenantId) {
        return store.filter!(m => m.tenantId == tenantId).array;
    }

    DomainMapping[] findByDomain(CustomDomainId domainId) {
        return store.filter!(m => m.customDomainId == domainId).array;
    }

    DomainMapping findByCustomRoute(TenantId tenantId, string customRoute) {
        foreach (m; store) {
            if (m.tenantId == tenantId && m.customRoute == customRoute)
                return m;
        }
        return DomainMapping.init;
    }

    void save(DomainMapping m) {
        store ~= m;
    }

    void update(DomainMapping m) {
        foreach (existing; store) {
            if (existing.id == m.id) {
                existing = m;
                return;
            }
        }
    }

    void remove(DomainMappingId id) {
        store = store.filter!(m => m.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(m => m.tenantId == tenantId).array.length;
    }
}
