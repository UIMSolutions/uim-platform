/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageProcessingPurposesUseCase {
    private IProcessingPurposeRepository repo;

    this(IProcessingPurposeRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createProcessingPurpose(CreateProcessingPurposeRequest r) {
        if (r.tenantId.isEmpty) return UsecaseResult(false, "", "Tenant ID is required");
        if (r.name.isEmpty) return UsecaseResult(false, "", "Purpose name is required");
        if (r.legalBasis.length == 0) return UsecaseResult(false, "", "Legal basis is required");

        ProcessingPurpose p;
        p.id = r.purposeId;
        p.tenantId = r.tenantId;
        p.name = r.name;
        p.description = r.description;
        p.legalBasis = r.legalBasis.to!LegalBasis;
        p.status = PurposeStatus.active;
        p.dataCategoryIds = r.dataCategoryIds;
        p.applicationIds = r.applicationIds;
        p.retentionPeriod = r.retentionPeriod;
        p.dataProtectionOfficer = r.dataProtectionOfficer;
        p.requiresConsent = r.requiresConsent;
        p.createdBy = r.createdBy;
        p.createdAt = currentTimestamp();

        repo.save(p);
        return UsecaseResult(true, p.id.value, "");
    }

    ProcessingPurpose getProcessingPurpose(TenantId tenantId, ProcessingPurposeId id) {
        return repo.findById(tenantId, id);
    }

    ProcessingPurpose[] listProcessingPurposes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateProcessingPurpose(UpdateProcessingPurposeRequest r) {
        auto existing = repo.findById(r.tenantId, r.purposeId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Processing purpose not found");

        if (r.name.length > 0) existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.legalBasis.length > 0) existing.legalBasis = r.legalBasis.to!LegalBasis;
        if (r.retentionPeriod.length > 0) existing.retentionPeriod = r.retentionPeriod;
        if (r.dataProtectionOfficer.length > 0) existing.dataProtectionOfficer = r.dataProtectionOfficer;
        existing.requiresConsent = r.requiresConsent;
        existing.updatedBy = r.updatedBy;
        existing.updatedAt = currentTimestamp();

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteProcessingPurpose(TenantId tenantId, ProcessingPurposeId id) {
        auto purpose = repo.findById(tenantId, id);
        if (purpose.isNull)
            return UsecaseResult(false, "", "Processing purpose not found");

        repo.remove(purpose);
        return UsecaseResult(true, purpose.id.value, "");
    }
}
