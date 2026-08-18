/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.application.usecases.manage.provisioning_jobs;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ManageProvisioningJobsUseCase {
    private IProvisioningJobRepository repo;

    this(IProvisioningJobRepository repo) { this.repo = repo; }

    ProvisioningJob getJob(TenantId tenantId, ProvisioningJobId id) { return repo.findById(tenantId, id); }
    ProvisioningJob[] listJobs(TenantId tenantId) { return repo.findByTenant(tenantId); }
    ProvisioningJob[] listByStatus(TenantId tenantId, JobStatus status) { return repo.findByStatus(tenantId, status); }

    UsecaseResult createJob(ProvisioningJobDTO dto) {
        auto j = ProvisioningJob(dto.tenantId);
        j.id = dto.jobId;
        j.name = dto.name;
        j.description = dto.description;
        j.sourceSystem = dto.sourceSystem;
        j.targetSystem = dto.targetSystem;
        j.status = JobStatus.pending;

        if (dto.type_.length > 0) {
            
            try { j.type_ = dto.type_.to!JobType; } catch (Exception) { j.type_ = JobType.read; }
        }

        if (!IdentityValidator.isValidProvisioningJob(j))
            return UsecaseResult(false, "", "Invalid job: sourceSystem and targetSystem are required");

        repo.save(j);
        return UsecaseResult(true, j.id.value, "");
    }

    UsecaseResult startJob(TenantId tenantId, ProvisioningJobId id) {
        
        auto j = repo.findById(tenantId, id);
        if (j.isNull) return UsecaseResult(false, "", "Provisioning job not found");
        if (j.status != JobStatus.pending)
            return UsecaseResult(false, "", "Job is not in pending state");
        j.status = JobStatus.running;
        j.startedAt = MonoTime.currTime.ticks;
        repo.update(j);
        return UsecaseResult(true, id.value, "");
    }

    UsecaseResult finishJob(TenantId tenantId, ProvisioningJobId id, bool success, string errorLog = "") {
        
        auto j = repo.findById(tenantId, id);
        if (j.isNull) return UsecaseResult(false, "", "Provisioning job not found");
        j.status = success ? JobStatus.success : JobStatus.failed;
        j.finishedAt = MonoTime.currTime.ticks;
        if (errorLog.length > 0) j.errorLog = errorLog;
        repo.update(j);
        return UsecaseResult(true, id.value, "");
    }

    UsecaseResult cancelJob(TenantId tenantId, ProvisioningJobId id) {
        auto j = repo.findById(tenantId, id);
        if (j.isNull) return UsecaseResult(false, "", "Provisioning job not found");
        if (j.status == JobStatus.success || j.status == JobStatus.failed)
            return UsecaseResult(false, "", "Cannot cancel a completed job");
        j.status = JobStatus.cancelled;
        repo.update(j);
        return UsecaseResult(true, id.value, "");
    }

    UsecaseResult deleteJob(TenantId tenantId, ProvisioningJobId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull) return UsecaseResult(false, "", "Provisioning job not found");
        repo.remove(entity);
        return UsecaseResult(true, id.value, "");
    }
}
