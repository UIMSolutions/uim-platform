module uim.platform.service_manager.domain.entities.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Operation {
    OperationId id;
    TenantId tenantId;
    string resourceId;
    string resourceType;
    OperationType type = OperationType.create;
    OperationStatus status = OperationStatus.pending;
    string description;
    string errorMessage;
    int rescheduleCount;
    long startedAt;
    long completedAt;
    long createdAt;
    long updatedAt;
}
