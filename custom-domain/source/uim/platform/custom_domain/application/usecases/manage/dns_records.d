/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageDnsRecordsUseCase : UIMUseCase {
    private DnsRecordRepository repo;

    this(DnsRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDnsRecordRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "ID is required");
        if (r.hostname.length == 0)
            return CommandResult(false, "", "Hostname is required");
        if (r.value.length == 0)
            return CommandResult(false, "", "Value is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "DNS record already exists");

        DnsRecord rec;
        rec.id = r.id;
        rec.tenantId = r.tenantId;
        rec.customDomainId = r.customDomainId;
        rec.hostname = r.hostname;
        rec.value = r.value;
        rec.ttl = r.ttl > 0 ? r.ttl : 3600;
        rec.validationStatus = DnsValidationStatus.pending;
        rec.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        rec.createdAt = now;
        rec.modifiedAt = now;

        repo.save(rec);
        return CommandResult(true, rec.id, "");
    }

    DnsRecord get_(DnsRecordId id) {
        return repo.findById(id);
    }

    DnsRecord[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DnsRecord[] listByDomain(CustomDomainId domainId) {
        return repo.findByDomain(domainId);
    }

    CommandResult update(UpdateDnsRecordRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "DNS record not found");

        if (r.value.length > 0)
            existing.value = r.value;
        if (r.ttl > 0)
            existing.ttl = r.ttl;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(DnsRecordId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "DNS record not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
