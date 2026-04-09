/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDnsRecordRepository : DnsRecordRepository {
    private DnsRecord[] store;

    DnsRecord findById(DnsRecordId id) {
        foreach (ref r; store) {
            if (r.id == id)
                return r;
        }
        return DnsRecord.init;
    }

    DnsRecord[] findByTenant(TenantId tenantId) {
        return store.filter!(r => r.tenantId == tenantId).array;
    }

    DnsRecord[] findByDomain(CustomDomainId domainId) {
        return store.filter!(r => r.customDomainId == domainId).array;
    }

    void save(DnsRecord r) {
        store ~= r;
    }

    void update(DnsRecord r) {
        foreach (ref existing; store) {
            if (existing.id == r.id) {
                existing = r;
                return;
            }
        }
    }

    void remove(DnsRecordId id) {
        store = store.filter!(r => r.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(r => r.tenantId == tenantId).array.length;
    }
}
