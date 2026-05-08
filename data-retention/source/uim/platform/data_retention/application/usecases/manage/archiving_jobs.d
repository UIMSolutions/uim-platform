module uim.platform.data_retention.application.usecases.manage.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageArchivingJobsUseCase { // TODO: UIMUseCase {
    private ArchivingJobRepository repo;

    this(ArchivingJobRepository repo) {
        this.repo = repo;
    }

    CommandResult createArchivingJob(CreateArchivingJobRequest req) {
        import std.uuid : randomUUID;

        if (req.applicationGroupId.length == 0)
            return CommandResult(false, "", "Application group ID is required");

        ArchivingJob aj;
        aj.id = ArchivingJobId(randomUUID().toString());
        aj.tenantId = req.tenantId;
        aj.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        aj.operationType = toArchivingJobOperationType(req.operationType);
        aj.status = ArchivingJobStatus.scheduled;
        aj.selectionCriteria = req.selectionCriteria;
        aj.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : clockSeconds();
        aj.createdBy = req.createdBy;
        aj.createdAt = clockSeconds();

        repo.save(aj);
        return CommandResult(true, aj.id.value, "");
    }

    CommandResult updateArchivingJob(ArchivingJobId id, UpdateArchivingJobRequest req) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Archiving job not found");

        auto aj = repo.findById(tenantId, id);
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


    bool hasArchivingJob(ArchivingJobId id) {
        return repo.existsById(id);
    }

    ArchivingJob getArchivingJob(ArchivingJobId id) {
        return repo.findById(tenantId, id);
    }

    ArchivingJob[] listArchivingJobs(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    ArchivingJob[] listArchivingJobs(TenantId tenantId, ArchivingJobStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult deleteArchivingJob(ArchivingJobId id) {
        auto job = repo.findById(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Archiving job not found");

        repo.remove(job);
        return CommandResult(true, job.id.value, "");
    }




}
