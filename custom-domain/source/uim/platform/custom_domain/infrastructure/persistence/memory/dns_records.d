/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDnsRecordRepository : TenantRepository!(DnsRecord, DnsRecordId), DnsRecordRepository {

    size_t countByDomain(CustomDomainId domainId) {
        return findByDomain(domainId).length;
    }

    DnsRecord[] findByDomain(CustomDomainId domainId) {
        return findAll().filter!(r => r.customDomainId == domainId).array;
    }

    void removeByDomain(CustomDomainId domainId) {
        findByDomain(domainId).each!(r => remove(r));
    }

}
