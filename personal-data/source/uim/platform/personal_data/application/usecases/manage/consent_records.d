/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageConsentRecordsUseCase {
    private IConsentRecordRepository repo;

    this(IConsentRecordRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createConsentRecord(CreateConsentRecordRequest r) {
        if (r.tenantId.isEmpty)
            return UsecaseResult(false, "", "Tenant ID is required");
        if (r.dataSubjectId.isEmpty)
            return UsecaseResult(false, "", "Data subject ID is required");
        if (r.purposeId.isEmpty)
            return UsecaseResult(false, "", "Purpose ID is required");

        ConsentRecord cr = ConsentRecord(r.tenantId);
        cr.id = r.recordId;
        cr.dataSubjectId = r.dataSubjectId;
        cr.purposeId = r.purposeId;
        cr.status = ConsentStatus.given;
        cr.consentText = r.consentText;
        cr.consentVersion = r.consentVersion;
        cr.givenAt = currentTimestamp();
        cr.expiresAt = r.expiresAt;
        cr.ipAddress = r.ipAddress;
        cr.userAgent = r.userAgent;
        cr.source = r.source;
        cr.createdBy = r.createdBy;
        cr.createdAt = currentTimestamp();

        repo.save(cr);
        return UsecaseResult(true, cr.id.value, "");
    }

    bool hasConsentRecord(TenantId tenantId, ConsentRecordId id) {
        return repo.existsById(tenantId, id);
    }

    ConsentRecord getConsentRecord(TenantId tenantId, ConsentRecordId id) {
        return repo.findById(tenantId, id);
    }

    ConsentRecord[] listConsentRecords(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ConsentRecord[] listConsentRecords(TenantId tenantId, DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(tenantId, dataSubjectId);
    }

    UsecaseResult withdrawConsentRecord(WithdrawConsentRequest r) {
        auto existing = repo.findById(r.tenantId, r.recordId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Consent record not found");

        existing.status = ConsentStatus.withdrawn;
        existing.withdrawnAt = currentTimestamp();
        existing.updatedAt = currentTimestamp();

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteConsentRecord(TenantId tenantId, ConsentRecordId id) {
        auto record = repo.findById(tenantId, id);
        if (record.isNull)
            return UsecaseResult(false, "", "Consent record not found");

        repo.remove(record);
        return UsecaseResult(true, record.id.value, "");
    }
}
