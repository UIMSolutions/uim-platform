module uim.platform.data_retention.application.usecases.manage.archiving_jobs;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class ManageArchivingJobsUseCase { // TODO: UIMUseCase {
    private ArchivingJobRepository repo;

    this(ArchivingJobRepository repo) {
        this.repo = repo;
    }

    CommandResult createArchivingJob(CreateArchivingJobRequest req) {
        import std.uuid : randomUUID;

        if (req.applicationGroupId.isEmpty)
            return CommandResult(false, "", "Application group ID is required");

        ArchivingJob aj;
        aj.initEntity(req.tenantId, req.createdBy);

        aj.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        aj.operationType = toArchivingJobOperationType(req.operationType);
        aj.status = ArchivingJobStatus.scheduled;
        aj.selectionCriteria = req.selectionCriteria;
        aj.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : clockSeconds();

        repo.save(aj);
        return CommandResult(true, aj.id.value, "");
    }

    CommandResult updateArchivingJob(TenantId tenantId, ArchivingJobId id, UpdateArchivingJobRequest req) {
        auto aj = repo.find(tenantId, id);
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
        aj.updatedAt = clockSeconds();

        repo.update(aj);
        return CommandResult(true, id.value, "");
    }


    bool hasArchivingJob(TenantId tenantId, ArchivingJobId id) {
        return repo.existsById(tenantId, id);
    }

    ArchivingJob getArchivingJob(TenantId tenantId, ArchivingJobId id) {
        return repo.find(tenantId, id);
    }

    ArchivingJob[] listArchivingJobs(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    ArchivingJob[] listArchivingJobs(TenantId tenantId, ArchivingJobStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult deleteArchivingJob(TenantId tenantId, ArchivingJobId id) {
        auto job = repo.find(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Archiving job not found");

        repo.remove(job);
        return CommandResult(true, job.id.value, "");
    }

}
