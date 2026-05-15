/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.domain_mappings;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDomainMappingRepository : TenantRepository!(DomainMapping, DomainMappingId), DomainMappingRepository {

    // #region ByCustomRoute
    DomainMapping findByCustomRoute(TenantId tenantId, string customRoute) {
        foreach (m; findByTenant(tenantId)) {
            if (m.customRoute == customRoute)
                return m;
        }
        return DomainMapping.init;
    }
    bool existsByCustomRoute(TenantId tenantId, string customRoute) {
        foreach (m; findByTenant(tenantId)) {
            if (m.customRoute == customRoute)
                return true;
        }
        return false;
    }
    void removeByCustomRoute(TenantId tenantId, string customRoute) {
        foreach (m; findByTenant(tenantId)) {
            if (m.customRoute == customRoute) {
                remove(m);
                return;
            }
        }
    }
    // #endregion ByCustomRoute

    // #region ByDomain
    size_t countByDomain(TenantId tenantId, CustomDomainId domainId) {
        return findByDomain(domainId).length;
    }

    DomainMapping[] filterByDomain(DomainMapping[] mappings, CustomDomainId domainId) {
        return mappings.filter!(m => m.customDomainId == domainId).array;
    }

    DomainMapping[] findByDomain(TenantId tenantId, CustomDomainId domainId) {
        return filterByDomain(findByTenant(tenantId), domainId);
    }

    void removeByDomain(TenantId tenantId, CustomDomainId domainId) {
        findByDomain(tenantId, domainId).each!(m => remove(m));
    }
    // #endregion ByDomain


}
