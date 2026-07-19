module uim.platform.task_center.application.dtos.taskaction;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct PerformTaskActionRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task action belongs, which is important for multi-tenancy support and ensuring that the action is performed in the correct context.
    TaskActionId actionId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task action with the same ID already exists, the service can return the existing action instead of creating a new one.
    TaskId taskId; // This is needed to link the action to the task on which it is performed, which is important for tracking and processing the action correctly.
    string actionType; // This is needed to specify the type of action being performed (e.g., claim, complete, delegate), which can help guide the processing of the action and ensure that it is handled correctly.
    UserId performedBy; // This is needed to identify the user who is performing the action, which is important for auditing and accountability purposes.
    string forwardTo; // This is needed if the action type is "delegate". It specifies the user to whom the task should be delegated. This field can be optional for other action types.
    string comment; // This is an optional field that can be used to provide additional information or context about the action being performed, which can be helpful for auditing and tracking purposes.
}

struct CreateTaskActionRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task action belongs, which is important for multi-tenancy support and ensuring that the action is performed in the correct context.
    TaskActionId actionId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task action with the same ID already exists, the service can return the existing action instead of creating a new one.
    TaskId taskId; // This is needed to link the action to the task on which it is performed, which is important for tracking and processing the action correctly.
    string actionType; // This is needed to specify the type of action being performed (e.g., claim, complete, delegate), which can help guide the processing of the action and ensure that it is handled correctly.
    UserId performedBy; // This is needed to identify the user who is performing the action, which is important for auditing and accountability purposes.
    string forwardTo; // This is needed if the action type is "delegate". It specifies the user to whom the task should be delegated. This field can be optional for other action types.
    string comment; // This is an optional field that can be used to provide additional information or context about the action being performed, which can be helpful for auditing and tracking purposes.
}

struct UpdateTaskActionRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task action belongs, which is important for multi-tenancy support and ensuring that the action is updated in the correct context.
    TaskActionId actionId; // This is needed to identify which task action to update. The client must pass the ID of the action to be updated.
    string comment; // This is an optional field that can be used to provide additional information or context about the update being performed on the action, which can be helpful for auditing and tracking purposes.
}   
