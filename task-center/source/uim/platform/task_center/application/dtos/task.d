module uim.platform.task_center.application.dtos.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateTaskRequest {
    TenantId tenantId;
    string id;
    string taskDefinitionId;
    string providerId;
    string externalTaskId;
    string title;
    string description;
    string priority;
    string category;
    string assignee;
    string creator;
    string sourceApplication;
    string dueDate;
    UserId createdBy;
}

struct UpdateTaskRequest {
    TenantId tenantId;
    string id;
    string title;
    string description;
    string priority;
    string assignee;
    string dueDate;
    UserId updatedBy;
}