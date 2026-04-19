/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageProcessingPurposesUseCase { // TODO: UIMUseCase {
    private ProcessingPurposeRepository repo;

    this(ProcessingPurposeRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateProcessingPurposeRequest r) {
        if (r.id.isEmpty) return CommandResult(false, "", "ID is required");
        if (r.name.length == 0) return CommandResult(false, "", "Purpose name is required");
        if (r.legalBasis.length == 0) return CommandResult(false, "", "Legal basis is required");

        import std.conv : to;

        ProcessingPurpose p;
        p.id = r.id;
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
        p.createdAt = clockTime();

        repo.save(p);
        return CommandResult(true, p.id, "");
    }

    ProcessingPurpose getById(ProcessingPurposeId id) {
        return repo.findById(id);
    }

    ProcessingPurpose[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateProcessingPurposeRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Processing purpose not found");

        import std.conv : to;

        if (r.name.length > 0) existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.legalBasis.length > 0) existing.legalBasis = r.legalBasis.to!LegalBasis;
        if (r.retentionPeriod.length > 0) existing.retentionPeriod = r.retentionPeriod;
        if (r.dataProtectionOfficer.length > 0) existing.dataProtectionOfficer = r.dataProtectionOfficer;
        existing.requiresConsent = r.requiresConsent;
        existing.modifiedBy = r.modifiedBy;
        existing.modifiedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ProcessingPurposeId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Processing purpose not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
