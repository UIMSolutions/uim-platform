/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.smartforms;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

class ManageSmartformsUseCase { // TODO: UIMUseCase {
    private SmartformRepository repo;

    this(SmartformRepository repo) {
        this.repo = repo;
    }

    Smartform getSmartform(TenantId tenantId, SmartformId id) {
        return repo.findById(tenantId, id);
    }

    Smartform[] listSmartforms(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Smartform[] listSmartforms(TenantId tenantId, ServiceCallId serviceCallId) {
        return repo.findByServiceCall(tenantId, serviceCallId);
    }

    Smartform[] listSmartforms(TenantId tenantId, ActivityId activityId) {
        return repo.findByActivity(tenantId, activityId);
    }

    CommandResult createSmartform(SmartformDTO dto) {
        Smartform sf;
        sf.id = dto.smartformId;
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
        return CommandResult(true, sf.id.value, "");
    }

    CommandResult updateSmartform(SmartformDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.smartformId);
        if (existing.isNull)
            return CommandResult(false, "", "Smartform not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.formData.length > 0) existing.formData = dto.formData;
        if (dto.signatureData.length > 0) existing.signatureData = dto.signatureData;
        if (!dto.submittedBy.isNull) existing.submittedBy = dto.submittedBy;
        if (dto.submittedDate.length > 0) existing.submittedDate = dto.submittedDate;
        if (!dto.approvedBy.isNull) existing.approvedBy = dto.approvedBy;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSmartform(TenantId tenantId, SmartformId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Smartform not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
