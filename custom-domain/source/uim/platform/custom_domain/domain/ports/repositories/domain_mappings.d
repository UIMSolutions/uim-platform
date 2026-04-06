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
    DomainMapping findById(DomainMappingId id);
    DomainMapping[] findByTenant(TenantId tenantId);
    DomainMapping[] findByDomain(CustomDomainId domainId);
    DomainMapping findByCustomRoute(TenantId tenantId, string customRoute);
    void save(DomainMapping m);
    void update(DomainMapping m);
    void remove(DomainMappingId id);
    long countByTenant(TenantId tenantId);
}
