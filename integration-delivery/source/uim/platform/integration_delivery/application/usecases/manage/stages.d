/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.stages;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class ManageStagesUseCase {
    private IStageRepository repo;

    this(IStageRepository repo) {
        this.repo = repo;
    }

    Stage getStage(TenantId tenantId, StageId id) {
        return repo.findById(tenantId, id);
    }

    Stage[] listStages(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Stage[] listByBuild(TenantId tenantId, BuildId buildId) {
        return repo.findByBuildOrdered(tenantId, buildId);
    }

    UsecaseResult createStage(StageDTO dto) {
        auto s = Stage(dto.tenantId); //, dto.createdBy);
        s.id = dto.stageId;
        s.buildId = dto.buildId;
        s.name = dto.name;
        s.order_ = dto.order_;
        s.isOptional = dto.isOptional;
        s.status = StageStatus.pending;

        if (!CicdValidator.isValidStage(s))
            return UsecaseResult(false, "", "Invalid stage data: name and buildId required");

        repo.save(s);
        return UsecaseResult(true, s.id.value, "");
    }

    UsecaseResult updateStage(StageDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.stageId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Stage not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteStage(TenantId tenantId, StageId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Stage not found");
        repo.remove(tenantId, id);
        return UsecaseResult(true, id.value, "");
    }
}
