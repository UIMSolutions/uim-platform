module uim.platform.data_retention.application.usecases.manage.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageArchivingJobsUseCase { // TODO: UIMUseCase {
    private ArchivingJobRepository repo;

    this(ArchivingJobRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateArchivingJobRequest req) {
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

    CommandResult update(string id, UpdateArchivingJobRequest req) {
        return update(ArchivingJobId(id), req);
    }

    CommandResult update(ArchivingJobId id, UpdateArchivingJobRequest req) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Archiving job not found");

        auto aj = repo.findById(id);
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

    bool hasById(string id) {
        return hasById(ArchivingJobId(id));
    }

    bool hasById(ArchivingJobId id) {
        return repo.existsById(id);
    }

    ArchivingJob getById(string id) {
        return getById(ArchivingJobId(id));
    }

    ArchivingJob getById(ArchivingJobId id) {
        return repo.findById(id);
    }

    ArchivingJob[] list(string tenantId) {
        return list(TenantId(tenantId));
    }

    ArchivingJob[] list(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    ArchivingJob[] listByStatus(TenantId tenantId, ArchivingJobStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult remove(string id) {
        return remove(ArchivingJobId(id));
    }

    CommandResult remove(ArchivingJobId id) {
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }




}
