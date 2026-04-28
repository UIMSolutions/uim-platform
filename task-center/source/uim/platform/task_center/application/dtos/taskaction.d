module uim.platform.task_center.application.dtos.taskaction;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct PerformTaskActionRequest {
    TenantId tenantId;
    string id;
    string taskId;
    string actionType;
    string performedBy;
    string forwardTo;
    string comment;
}