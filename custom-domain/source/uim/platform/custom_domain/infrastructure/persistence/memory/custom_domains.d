/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.custom_domains;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryCustomDomainRepository : TenantRepository!(CustomDomain, CustomDomainId), CustomDomainRepository {

    CustomDomain findByDomainName(TenantId tenantId, string domainName) {
        foreach (d; findByTenant(tenantId)) {
            if (d.domainName == domainName)
                return d;
        }
        return CustomDomain.init;
    }

    // #region ByOrganization
    size_t countByOrganization(TenantId tenantId, string organizationId) {
        return findByOrganization(tenantId, organizationId).length;
    }

    CustomDomain[] filterByOrganization(CustomDomain[] domains, string organizationId) {
        return domains.filter!(d => d.organizationId == organizationId).array;
    }

    CustomDomain[] findByOrganization(TenantId tenantId, string organizationId) {
        return filterByOrganization(findByTenant(tenantId), organizationId);
    }

    void removeByOrganization(TenantId tenantId, string organizationId) {
        findByOrganization(tenantId, organizationId).each!(d => remove(d));
    }
    // #endregion ByOrganization

}
