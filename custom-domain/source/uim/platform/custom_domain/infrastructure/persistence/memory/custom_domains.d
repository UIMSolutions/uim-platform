/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.custom_domains;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryCustomDomainRepository : CustomDomainRepository {
    private CustomDomain[] store;

    CustomDomain findById(CustomDomainId id) {
        foreach (ref d; store) {
            if (d.id == id)
                return d;
        }
        return CustomDomain.init;
    }

    CustomDomain findByDomainName(TenantId tenantId, string domainName) {
        foreach (ref d; store) {
            if (d.tenantId == tenantId && d.domainName == domainName)
                return d;
        }
        return CustomDomain.init;
    }

    CustomDomain[] findByTenant(TenantId tenantId) {
        return store.filter!(d => d.tenantId == tenantId).array;
    }

    CustomDomain[] findByOrganization(TenantId tenantId, string organizationId) {
        return store.filter!(d => d.tenantId == tenantId && d.organizationId == organizationId).array;
    }

    void save(CustomDomain d) {
        store ~= d;
    }

    void update(CustomDomain d) {
        foreach (ref existing; store) {
            if (existing.id == d.id) {
                existing = d;
                return;
            }
        }
    }

    void remove(CustomDomainId id) {
        store = store.filter!(d => d.id != id).array;
    }

    long countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(d => d.tenantId == tenantId).array.length;
    }
}
