/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.pipelines;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class ManagePipelinesUseCase {
    private PipelineRepository repo;

    this(PipelineRepository repo) {
        this.repo = repo;
    }

    Pipeline getPipeline(TenantId tenantId, PipelineId id) {
        return repo.findById(tenantId, id);
    }

    Pipeline[] listPipelines(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Pipeline[] listActive(TenantId tenantId) {
        return repo.findByStatus(tenantId, PipelineStatus.active);
    }

    CommandResult createPipeline(PipelineDTO dto) {
        Pipeline p;
        p.initEntity(dto.tenantId, dto.createdBy);
        p.id = dto.pipelineId;
        p.name = dto.name;
        p.description = dto.description;
        p.configurationYaml = dto.configurationYaml;
        p.version_ = dto.version_.length > 0 ? dto.version_ : "1.0.0";
        p.status = PipelineStatus.active;

        if (!CicdValidator.isValidPipeline(p))
            return CommandResult(false, "", "Invalid pipeline data");

        repo.save(p);
        return CommandResult(true, p.id.value, "");
    }

    CommandResult updatePipeline(PipelineDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.pipelineId);
        if (existing.isNull)
            return CommandResult(false, "", "Pipeline not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.configurationYaml.length > 0) existing.configurationYaml = dto.configurationYaml;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePipeline(TenantId tenantId, PipelineId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Pipeline not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
