module uim.platform.data_retention.application.usecases.manage.deletion_requests;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDeletionRequestsUseCase { // TODO: UIMUseCase {
    private DeletionRequestRepository repo;

    this(DeletionRequestRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDeletionRequestRequest req) {
        import std.uuid : randomUUID;

        if (req.dataSubjectId.length == 0)
            return CommandResult(false, "", "Data subject ID is required");

        DeletionRequest dr;
        dr.id = DeletionRequestId(randomUUID().toString());
        dr.tenantId = req.tenantId;
        dr.dataSubjectId = DataSubjectId(req.dataSubjectId);
        dr.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        dr.actionType = parseDeletionActionType(req.actionType);
        dr.status = DeletionRequestStatus.pending;
        dr.reason = req.reason;
        dr.requestedBy = req.requestedBy;
        dr.requestedAt = clockSeconds();
        dr.createdAt = clockSeconds();

        repo.save(dr);
        return CommandResult(true, dr.id.value, "");
    }

    CommandResult update(string id, UpdateDeletionRequestRequest req) {
        return update(DeletionRequestId(id), req);
    }

    CommandResult update(DeletionRequestId id, UpdateDeletionRequestRequest req) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Deletion request not found");

        auto dr = repo.findById(tenantId, id);
        if (req.status.length > 0)
            dr.status = parseDeletionRequestStatus(req.status);
        if (req.errorMessage.length > 0)
            dr.errorMessage = req.errorMessage;
        if (dr.status == DeletionRequestStatus.completed)
            dr.completedAt = clockSeconds();
        dr.updatedAt = clockSeconds();

        repo.update(dr);
        return CommandResult(true, id.value, "");
    }

    bool hasById(DeletionRequestId id) {
        return repo.existsById(id);
    }

    DeletionRequest getById(DeletionRequestId id) {
        return repo.findById(tenantId, id);
    }

    DeletionRequest[] list(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    DeletionRequest[] listByStatus(TenantId tenantId, DeletionRequestStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult deleteDeletionRequest(DeletionRequestId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Deletion request not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }

    private static DeletionActionType parseDeletionActionType(string s) {
        switch (s) {
        case "block":
            return DeletionActionType.block;
        case "delete":
            return DeletionActionType.delete_;
        case "anonymize":
            return DeletionActionType.anonymize;
        default:
            return DeletionActionType.delete_;
        }
    }

    private static DeletionRequestStatus parseDeletionRequestStatus(string s) {
        switch (s) {
        case "pending":
            return DeletionRequestStatus.pending;
        case "inProgress":
            return DeletionRequestStatus.inProgress;
        case "completed":
            return DeletionRequestStatus.completed;
        case "failed":
            return DeletionRequestStatus.failed;
        case "cancelled":
            return DeletionRequestStatus.cancelled;
        default:
            return DeletionRequestStatus.pending;
        }
    }
}
