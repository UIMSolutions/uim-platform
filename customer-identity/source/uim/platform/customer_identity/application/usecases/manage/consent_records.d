/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.consent_records;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ManageConsentRecordsUseCase {
    private ConsentRecordRepository repo;

    this(ConsentRecordRepository repo) {
        this.repo = repo;
    }

    ConsentRecord getConsentRecord(TenantId tenantId, ConsentRecordId id) {
        return repo.findById(tenantId, id);
    }

    ConsentRecord[] listConsentRecords(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ConsentRecord[] listByCustomer(TenantId tenantId, CustomerId customerId) {
        return repo.findByCustomer(tenantId, customerId);
    }

    CommandResult grantConsent(ConsentRecordDTO dto) {
        import core.time : MonoTime;
        ConsentRecord cr;
        cr.initEntity(dto.tenantId, dto.createdBy);
        cr.customerId = dto.customerId;
        cr.purpose = dto.purpose;
        cr.granted = true;
        cr.grantedAt = MonoTime.currTime.ticks;
        cr.ipAddress = dto.ipAddress;
        cr.userAgent = dto.userAgent;
        cr.version_ = dto.version_;
        cr.locale = dto.locale;

        import std.conv : to;
        try { cr.consentType = dto.consentType.to!ConsentType; }
        catch (Exception) { return CommandResult(false, "", "Invalid consent type"); }
        try { cr.legalBasis = dto.legalBasis.to!LegalBasis; }
        catch (Exception) { return CommandResult(false, "", "Invalid legal basis"); }

        if (!IdentityValidator.isValidConsentRecord(cr))
            return CommandResult(false, "", "Invalid consent record");

        repo.save(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult revokeConsent(TenantId tenantId, ConsentRecordId id) {
        import core.time : MonoTime;
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Consent record not found");

        existing.granted = false;
        existing.revokedAt = MonoTime.currTime.ticks;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult revokeAllConsents(TenantId tenantId, CustomerId customerId) {
        repo.revokeByCustomer(tenantId, customerId);
        return CommandResult(true, customerId.value, "");
    }

    CommandResult deleteConsentRecord(TenantId tenantId, ConsentRecordId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Consent record not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
