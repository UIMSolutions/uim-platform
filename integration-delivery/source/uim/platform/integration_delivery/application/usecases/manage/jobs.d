/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.jobs;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class ManageJobsUseCase {
    private JobRepository repo;

    this(JobRepository repo) {
        this.repo = repo;
    }

    Job getJob(TenantId tenantId, JobId id) {
        return repo.findById(tenantId, id);
    }

    Job[] listJobs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Job[] listByPipeline(TenantId tenantId, PipelineId pipelineId) {
        return repo.findByPipeline(tenantId, pipelineId);
    }

    Job[] listByRepository(TenantId tenantId, CicdRepositoryId repositoryId) {
        return repo.findByRepository(tenantId, repositoryId);
    }

    CommandResult createJob(JobDTO dto) {
        auto j = Job(dto.tenantId, dto.createdBy);
        j.id = dto.jobId;
        j.name = dto.name;
        j.description = dto.description;
        j.pipelineId = dto.pipelineId;
        j.repositoryId = dto.repositoryId;
        j.branch = dto.branch.length > 0 ? dto.branch : "main";
        j.cronExpression = dto.cronExpression;
        j.deploymentTargetId = dto.deploymentTargetId;
        j.configurationSource = dto.configurationSource;
        j.notifyOnSuccess = dto.notifyOnSuccess;
        j.notifyOnFailure = dto.notifyOnFailure;
        j.notificationEmail = dto.notificationEmail;
        j.status = JobStatus.active;

        if (!CicdValidator.isValidJob(j))
            return CommandResult(false, "", "Invalid job data: name, pipelineId and repositoryId required");

        repo.save(j);
        return CommandResult(true, j.id.value, "");
    }

    CommandResult updateJob(JobDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.jobId);
        if (existing.isNull)
            return CommandResult(false, "", "Job not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.branch.length > 0) existing.branch = dto.branch;
        if (dto.cronExpression.length > 0) existing.cronExpression = dto.cronExpression;
        if (dto.notificationEmail.length > 0) existing.notificationEmail = dto.notificationEmail;
        existing.notifyOnSuccess = dto.notifyOnSuccess;
        existing.notifyOnFailure = dto.notifyOnFailure;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteJob(TenantId tenantId, JobId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Job not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
