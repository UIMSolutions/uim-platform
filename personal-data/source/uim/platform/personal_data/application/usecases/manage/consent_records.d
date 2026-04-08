/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageConsentRecordsUseCase : UIMUseCase {
    private ConsentRecordRepository repo;

    this(ConsentRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateConsentRecordRequest r) {
        if (r.id.isEmpty) return CommandResult(false, "", "ID is required");
        if (r.dataSubjectid.isEmpty) return CommandResult(false, "", "Data subject ID is required");
        if (r.purposeid.isEmpty) return CommandResult(false, "", "Purpose ID is required");

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
        return CommandResult(true, cr.id, "");
    }

    ConsentRecord get_(ConsentRecordId id) {
        return repo.findById(id);
    }

    ConsentRecord[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ConsentRecord[] listByDataSubject(DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(dataSubjectId);
    }

    CommandResult withdraw(WithdrawConsentRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Consent record not found");

        existing.status = ConsentStatus.withdrawn;
        existing.withdrawnAt = clockTime();
        existing.modifiedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ConsentRecordId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Consent record not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
