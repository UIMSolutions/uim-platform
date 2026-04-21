/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.domain_mappings;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface DomainMappingRepository {

    bool findByCustomRoute(TenantId tenantId, string customRoute);
    DomainMapping findByCustomRoute(TenantId tenantId, string customRoute);
    void removeByCustomRoute(TenantId tenantId, string customRoute);

    size_t countByDomain(CustomDomainId domainId);
    DomainMapping[] findByDomain(CustomDomainId domainId);
    void removeByDomain(CustomDomainId domainId);
        
}
