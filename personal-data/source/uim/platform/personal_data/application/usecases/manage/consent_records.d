/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.consent_records;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class ManageConsentRecordsUseCase { // TODO: UIMUseCase {
    private ConsentRecordRepository repo;

    this(ConsentRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult createConsentRecord(CreateConsentRecordRequest r) {
        if (r.tenantId.isEmpty)
            return CommandResult(false, "", "Tenant ID is required");
        if (r.dataSubjectId.isEmpty)
            return CommandResult(false, "", "Data subject ID is required");
        if (r.purposeId.isEmpty)
            return CommandResult(false, "", "Purpose ID is required");

        ConsentRecord cr;
        cr.id = r.id;
        cr.tenantId = r.tenantId;
        cr.dataSubjectId = r.dataSubjectId;
        cr.purposeId = r.purposeId;
        cr.status = ConsentStatus.given;
        cr.consentText = r.consentText;
        cr.consentVersion = r.consentVersion;
        cr.givenAt = clockTime();
        cr.expiresAt = r.expiresAt;
        cr.ipAddress = r.ipAddress;
        cr.userAgent = r.userAgent;
        cr.source = r.source;
        cr.createdBy = r.createdBy;
        cr.createdAt = clockTime();

        repo.save(cr);
        return CommandResult(true, cr.id.value, "");
    }

    bool hasConsentRecord(TenantId tenantId, ConsentRecordId id) {
        return repo.existsById(tenantId, id);
    }

    ConsentRecord getConsentRecord(ConsentRecordId id) {
        return repo.findById(tenantId, id);
    }

    ConsentRecord[] listConsentRecordsByTenant(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ConsentRecord[] listConsentRecords(TenantId tenantId, DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(tenantId, dataSubjectId);
    }

    CommandResult withdrawConsentRecord(WithdrawConsentRequest r) {
        auto existing = repo.find(r.tenantId, r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Consent record not found");

        existing.status = ConsentStatus.withdrawn;
        existing.withdrawnAt = clockTime();
        existing.updatedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteConsentRecord(TenantId tenantId, ConsentRecordId id) {
        auto record = repo.findById(tenantId, id);
        if (record.isNull)
            return CommandResult(false, "", "Consent record not found");

        repo.remove(record);
        return CommandResult(true, record.id.value, "");
    }
}
