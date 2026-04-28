module uim.platform.task_center.application.dtos.taskdefinition;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateTaskDefinitionRequest {
    TenantId tenantId;
    string id;
    string providerId;
    string name;
    string description;
    string category;
    string taskSchema;
    bool requiresClaim;
    string createdBy;
}

struct UpdateTaskDefinitionRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string category;
    string taskSchema;
    bool requiresClaim;
    string modifiedBy;
}
