/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface DnsRecordRepository : ITentRepository!(DnsRecord, DnsRecordId) {

    size_t countByDomain(TenantId tenantId, CustomDomainId domainId);
    DnsRecord[] findByDomain(TenantId tenantId, CustomDomainId domainId);
    void removeByDomain(TenantId tenantId, CustomDomainId domainId);
    
}
