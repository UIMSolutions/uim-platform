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
    private IConsentRecordRepository repo;

    this(IConsentRecordRepository repo) {
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

    UsecaseResult grantConsent(ConsentRecordDTO dto) {
        
        auto cr = ConsentRecord(dto.tenantId);
        cr.customerId = dto.customerId;
        cr.purpose = dto.purpose;
        cr.granted = true;
        cr.grantedAt = MonoTime.currTime.ticks;
        cr.ipAddress = dto.ipAddress;
        cr.userAgent = dto.userAgent;
        cr.version_ = dto.version_;
        cr.locale = dto.locale;

        
        try { cr.consentType = dto.consentType.to!ConsentType; }
        catch (Exception) { return UsecaseResult(false, "", "Invalid consent type"); }
        try { cr.legalBasis = dto.legalBasis.to!LegalBasis; }
        catch (Exception) { return UsecaseResult(false, "", "Invalid legal basis"); }

        if (!IdentityValidator.isValidConsentRecord(cr))
            return UsecaseResult(false, "", "Invalid consent record");

        repo.save(cr);
        return UsecaseResult(true, cr.id.value, "");
    }

    UsecaseResult revokeConsent(TenantId tenantId, ConsentRecordId id) {
        
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Consent record not found");

        existing.granted = false;
        existing.revokedAt = MonoTime.currTime.ticks;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult revokeAllConsents(TenantId tenantId, CustomerId customerId) {
        repo.revokeByCustomer(tenantId, customerId);
        return UsecaseResult(true, customerId.value, "");
    }

    UsecaseResult deleteConsentRecord(TenantId tenantId, ConsentRecordId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Consent record not found");

        repo.remove(existing);
        return UsecaseResult(true, existing.id.value, "");
    }
}
