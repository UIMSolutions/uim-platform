/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.dns_records;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageDnsRecordsUseCase { // TODO: UIMUseCase {
    private DnsRecordRepository repo;

    this(DnsRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult createDnsRecord(CreateDnsRecordRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "ID is required");
        if (r.hostname.length == 0)
            return CommandResult(false, "", "Hostname is required");
        if (r.value.length == 0)
            return CommandResult(false, "", "Value is required");

        auto existing = repo.findById(r.tenantId, r.id);
        if (!existing.isNull)
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
        auto now = currentTimestamp;
        rec.createdAt = now;
        rec.updatedAt = now;

        repo.save(rec);
        return CommandResult(true, rec.id.value, "");
    }

    DnsRecord getDnsRecordById(TenantId tenantId, DnsRecordId id) {
        return repo.findById(tenantId, id);
    }

    DnsRecord[] listDnsRecords(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DnsRecord[] listDnsRecords(TenantId tenantId, CustomDomainId domainId) {
        return repo.findByDomain(tenantId, domainId);
    }

    CommandResult updateDnsRecord(UpdateDnsRecordRequest r) {
        auto record = repo.findById(r.tenantId, r.id);
        if (record.isNull)
            return CommandResult(false, "", "DNS record not found");

        if (r.value.length > 0)
            record.value = r.value;
        if (r.ttl > 0)
            record.ttl = r.ttl;

        import core.time : MonoTime;
        record.updatedAt = currentTimestamp;

        repo.update(record);
        return CommandResult(true, record.id.value, "");
    }

    CommandResult deleteDnsRecord(TenantId tenantId, DnsRecordId id) {
        auto record = repo.findById(tenantId, id);
        if (record.isNull)
            return CommandResult(false, "", "DNS record not found");

        repo.remove(record);
        return CommandResult(true, record.id.value, "");
    }
}
