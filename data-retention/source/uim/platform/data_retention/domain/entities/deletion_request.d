module uim.platform.data_retention.domain.entities.deletion_request;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DeletionRequest {
    DeletionRequestId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    ApplicationGroupId applicationGroupId;
    DeletionActionType actionType = DeletionActionType.delete_;
    DeletionRequestStatus status = DeletionRequestStatus.pending;
    string reason;
    string requestedBy;
    long requestedAt;
    long completedAt;
    string errorMessage;
    long createdAt;
    long updatedAt;
}
