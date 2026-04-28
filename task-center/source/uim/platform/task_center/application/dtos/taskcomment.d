module uim.platform.task_center.application.dtos.taskcomment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateTaskCommentRequest {
    TenantId tenantId;
    string id;
    string taskId;
    string author;
    string content;
}

struct UpdateTaskCommentRequest {
    TenantId tenantId;
    string id;
    string content;
}