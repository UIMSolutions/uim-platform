/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageArchivingJobsUseCase {
    private IArchivingJobRepository repo;

    this(IArchivingJobRepository repo) {
        this.repo = repo;
    }

    CommandResult createArchivingJob(CreateArchivingJobRequest req) {
        import std.uuid : randomUUID;

        if (req.groupId.isNull)
            return CommandResult(false, "", "Application group ID is required");

        auto aj = ArchivingJob(req.tenantId, ArchivingJobId(generateId), req.createdBy);
        aj.groupId = req.groupId;
        aj.operationType = req.operationType.toArchivingOperationType;
        aj.status = ArchivingJobStatus.scheduled;
        aj.selectionCriteria = req.selectionCriteria;
        aj.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : clockSeconds();

        repo.save(aj);
        return CommandResult(true, aj.id.value, "");
    }

    CommandResult updateArchivingJob(UpdateArchivingJobRequest req) {
        auto aj = repo.findById(req.tenantId, req.jobId);
        if (aj.isNull)
            return CommandResult(false, "", "Archiving job not found");

        if (req.status.length > 0)
            aj.status = toArchivingJobStatus(req.status);
        if (req.recordsProcessed > 0)
            aj.recordsProcessed = req.recordsProcessed;
        if (req.recordsFailed > 0)
            aj.recordsFailed = req.recordsFailed;
        if (req.errorMessage.length > 0)
            aj.errorMessage = req.errorMessage;
        if (aj.status == ArchivingJobStatus.running)
            aj.startedAt = clockSeconds();
        if (aj.status == ArchivingJobStatus.completed || aj.status == ArchivingJobStatus.failed)
            aj.completedAt = clockSeconds();
        aj.updatedAt = currentTimestamp();

        repo.update(aj);
        return CommandResult(true, aj.id.value, "");
    }

    bool hasArchivingJob(TenantId tenantId, ArchivingJobId id) {
        return repo.existsById(tenantId, id);
    }

    ArchivingJob getArchivingJob(TenantId tenantId, ArchivingJobId id) {
        return repo.findById(tenantId, id);
    }

    ArchivingJob[] listArchivingJobs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ArchivingJob[] listArchivingJobs(TenantId tenantId, ArchivingJobStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult deleteArchivingJob(TenantId tenantId, ArchivingJobId id) {
        auto job = repo.findById(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Archiving job not found");

        repo.remove(job);
        return CommandResult(true, job.id.value, "");
    }

}
