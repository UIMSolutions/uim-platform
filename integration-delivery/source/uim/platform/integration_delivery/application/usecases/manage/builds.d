/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.builds;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class ManageBuildsUseCase {
    private IBuildRepository repo;

    this(IBuildRepository repo) {
        this.repo = repo;
    }

    Build getBuild(TenantId tenantId, BuildId id) {
        return repo.findById(tenantId, id);
    }

    Build[] listBuilds(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Build[] listByJob(TenantId tenantId, JobId jobId) {
        return repo.findByJob(tenantId, jobId);
    }

    Build[] listByStatus(TenantId tenantId, BuildStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    Build findLatestByJob(TenantId tenantId, JobId jobId) {
        return repo.findLatestByJob(tenantId, jobId);
    }

    UsecaseResult triggerBuild(BuildDTO dto) {
        auto b = Build(dto.tenantId); //, dto.createdBy);
        b.id = dto.buildId;
        b.jobId = dto.jobId;
        b.commitSha = dto.commitSha;
        b.branch = dto.branch;
        b.commitMessage = dto.commitMessage;
        b.commitAuthor = dto.commitAuthor;
        b.triggerInfo = dto.triggerInfo;
        b.status = BuildStatus.pending;

        if (!CicdValidator.isValidBuild(b))
            return UsecaseResult(false, "", "Invalid build data: jobId required");

        repo.save(b);
        return UsecaseResult(true, b.id.value, "");
    }

    UsecaseResult updateBuildStatus(TenantId tenantId, BuildId id, BuildStatus status, string errorMessage = "") {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Build not found");

        existing.status = status;
        if (errorMessage.length > 0) existing.errorMessage = errorMessage;
        if (status == BuildStatus.running && existing.startedAt == 0)
            existing.startedAt = 0; // caller sets timestamp
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult cancelBuild(TenantId tenantId, BuildId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Build not found");
        if (existing.status != BuildStatus.running && existing.status != BuildStatus.pending)
            return UsecaseResult(false, "", "Build cannot be cancelled in current state");

        existing.status = BuildStatus.cancelled;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteBuild(TenantId tenantId, BuildId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Build not found");
        repo.remove(tenantId, id);
        return UsecaseResult(true, id.value, "");
    }
}
