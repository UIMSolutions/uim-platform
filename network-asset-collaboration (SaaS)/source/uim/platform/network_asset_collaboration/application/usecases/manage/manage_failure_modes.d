/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.usecases.manage.manage_failure_modes;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class ManageFailureModesUseCase : UIMUseCase {
    private FailureModeRepository repo;

    this(FailureModeRepository repo) {
        this.repo = repo;
    }

    FailureMode* get_(FailureModeId id) {
        return repo.findById(id);
    }

    FailureMode[] list() {
        return repo.findAll();
    }

    FailureMode[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    FailureMode[] listByModel(string modelId) {
        return repo.findByModel(modelId);
    }

    FailureMode[] listBySeverity(FailureSeverity severity) {
        return repo.findBySeverity(severity);
    }

    CommandResult create(FailureModeDTO dto) {
        FailureMode fm;
        fm.id = dto.id;
        fm.tenantId = dto.tenantId;
        fm.modelId = dto.modelId;
        fm.name = dto.name;
        fm.description = dto.description;
        fm.cause = dto.cause;
        fm.effect = dto.effect;
        fm.detection = dto.detection;
        fm.mitigation = dto.mitigation;
        fm.riskPriorityNumber = dto.riskPriorityNumber;
        fm.createdBy = dto.createdBy;
        if (!AssetValidator.isValidFailureMode(fm))
            return CommandResult(false, "", "Invalid failure mode data");
        repo.save(fm);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(FailureModeDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Failure mode not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.cause.length > 0) existing.cause = dto.cause;
        if (dto.mitigation.length > 0) existing.mitigation = dto.mitigation;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(FailureModeId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Failure mode not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
