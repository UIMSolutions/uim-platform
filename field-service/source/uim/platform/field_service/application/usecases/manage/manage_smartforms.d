/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage_smartforms;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageSmartformsUseCase : UIMUseCase {
    private SmartformRepository repo;

    this(SmartformRepository repo) {
        this.repo = repo;
    }

    Smartform* get_(SmartformId id) {
        return repo.findById(id);
    }

    Smartform[] list() {
        return repo.findAll();
    }

    Smartform[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Smartform[] listByServiceCall(ServiceCallId serviceCallId) {
        return repo.findByServiceCall(serviceCallId);
    }

    Smartform[] listByActivity(ActivityId activityId) {
        return repo.findByActivity(activityId);
    }

    CommandResult create(SmartformDTO dto) {
        Smartform sf;
        sf.id = dto.id;
        sf.tenantId = dto.tenantId;
        sf.serviceCallId = dto.serviceCallId;
        sf.activityId = dto.activityId;
        sf.name = dto.name;
        sf.description = dto.description;
        sf.templateId = dto.templateId;
        sf.safetyLabel = dto.safetyLabel;
        sf.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidSmartform(sf))
            return CommandResult(false, "", "Invalid smartform data");
        repo.save(sf);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(SmartformDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Smartform not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.formData.length > 0) existing.formData = dto.formData;
        if (dto.signatureData.length > 0) existing.signatureData = dto.signatureData;
        if (dto.submittedBy.length > 0) existing.submittedBy = dto.submittedBy;
        if (dto.submittedDate.length > 0) existing.submittedDate = dto.submittedDate;
        if (dto.approvedBy.length > 0) existing.approvedBy = dto.approvedBy;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(SmartformId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Smartform not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
