module uim.platform.data_retention.domain.entities.deletion_request;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DeletionRequest {
    mixin TenantEntity!(DeletionRequestId);

    DataSubjectId subjectId;
    ApplicationGroupId groupId;
    DeletionActionType actionType = DeletionActionType.delete_;
    DeletionRequestStatus status = DeletionRequestStatus.pending;

    string reason;
    UserId requestedBy;
    long requestedAt;
    long completedAt;
    string errorMessage;
    
    Json toJson() const {
        return entityToJson
            .set("dataSubjectId", subjectId.value)
            .set("applicationGroupId", groupId.value)
            .set("actionType", actionType.to!string())
            .set("status", status.to!string())
            .set("reason", reason)
            .set("requestedBy", requestedBy)
            .set("requestedAt", requestedAt)
            .set("completedAt", completedAt)
            .set("errorMessage", errorMessage);
    }
}
