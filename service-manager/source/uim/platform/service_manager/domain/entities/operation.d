module uim.platform.service_manager.domain.entities.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Operation {
    mixin TenantEntity!(OperationId);

    string resourceId;
    string resourceType;
    OperationType type = OperationType.create;
    OperationStatus status = OperationStatus.pending;
    string description;
    string errorMessage;
    int rescheduleCount;
    long startedAt;
    long completedAt;

    Json toJson() const {
        return entityToJson
            .set("resourceId", resourceId)
            .set("resourceType", resourceType)
            .set("type", type.toString())
            .set("status", status.toString())
            .set("description", description)
            .set("errorMessage", errorMessage)
            .set("rescheduleCount", rescheduleCount)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt);
    }
}
