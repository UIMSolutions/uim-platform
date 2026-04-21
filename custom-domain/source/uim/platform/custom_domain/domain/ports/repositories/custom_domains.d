/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.custom_domains;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface CustomDomainRepository : ITenantRepository!(CustomDomain, CustomDomainId) {
    
    size_t countByDomainName(TenantId tenantId, string domainName);
    CustomDomain findByDomainName(TenantId tenantId, string domainName);
    void removeByDomainName(TenantId tenantId, string domainName);

    size_t countByOrganization(TenantId tenantId, string organizationId);
    CustomDomain[] findByOrganization(TenantId tenantId, string organizationId);
    void removeByOrganization(TenantId tenantId, string organizationId);
    
}
