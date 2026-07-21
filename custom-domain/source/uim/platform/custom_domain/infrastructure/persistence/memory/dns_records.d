/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.repositories.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDnsRecordRepository : TenantRepository!(DnsRecord, DnsRecordId), DnsRecordRepository {

    size_t countByDomain(TenantId tenantId, CustomDomainId domainId) {
        return findByDomain(tenantId, domainId).length;
    }

    DnsRecord[] filterByDomain(DnsRecord[] records, CustomDomainId domainId) {
        return records.filter!(r => r.customDomainId == domainId).array;
    }

    DnsRecord[] findByDomain(TenantId tenantId, CustomDomainId domainId) {
        return filterByDomain(findByTenant(tenantId), domainId);
    }

    void removeByDomain(TenantId tenantId, CustomDomainId domainId) {
        findByDomain(tenantId, domainId).each!(r => remove(r));
    }

}
