/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface DnsRecordRepository {
    DnsRecord findById(DnsRecordId id);
    DnsRecord[] findByTenant(TenantId tenantId);
    DnsRecord[] findByDomain(CustomDomainId domainId);
    void save(DnsRecord r);
    void update(DnsRecord r);
    void remove(DnsRecordId id);
    long countByTenant(TenantId tenantId);
}
