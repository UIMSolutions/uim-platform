module uim.platform.task_center.application.dtos.task;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:
struct CreateTaskRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task belongs, which is important for multi-tenancy support and ensuring that the task is created in the correct context.
    TaskId taskId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task with the same ID already exists, the service can return the existing task instead of creating a new one.
    TaskDefinitionId definitionId; // This is needed to link the task to its definition, which contains the template and rules for the task.
    TaskProviderId providerId; // This is needed to identify which provider is responsible for this task, which can be important for routing and processing the task correctly.
    TaskId externalTaskId; // This is needed to link the task to an external system or process, which can be important for tracking and integration purposes.
    string title; // The title of the task. This is a required field, as it provides a brief summary of the task and is often used in task lists and notifications.
    string description; // The description of the task. This is an optional field, but it can provide additional details and context about the task, which can be helpful for the assignee and other stakeholders.
    string priority; // The priority of the task. This is an optional field, but it can be used to indicate the urgency or importance of the task, which can help the assignee prioritize their work and ensure that critical tasks are addressed in a timely manner.
    string category; // The category of the task. This is an optional field, but it can be used to classify tasks and make it easier to filter and organize them.
    string assignee; // The assignee of the task. This is an optional field, but it can be used to assign the task to a specific user or group, which can help ensure that the task is completed by the right person.
    string creator; // The creator of the task. This is an optional field, but it can be used to track who created the task, which can be important for auditing and accountability purposes.
    string sourceApplication; // The source application of the task. This is an optional field, but it can be used to identify which application or system originated the task, which can be important for integration and tracking purposes.
    string dueDate; // The due date of the task. This is an optional field, but it can be used to indicate when the task is expected to be completed, which can help the assignee prioritize their work and ensure timely completion.
    UserId createdBy; // The user who is creating the task. This is important for auditing purposes, as it allows the system to track who created the task.
    string[] allowedActions; // The allowed actions for the task. This is an optional field, but it can be used to specify which actions can be performed on the task (e.g., claim, complete, delegate), which can help guide the assignee and ensure that the task is processed correctly.
    string[string] customAttributes; // Custom attributes for the task. This is an optional field, but it can be used to store additional information about the task that may be relevant for processing or
}

struct UpdateTaskRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task belongs, which is important for multi-tenancy support and ensuring that the task is updated in the correct context.
    TaskId taskId; // This is needed to identify which task to update. The client must pass the ID of the task to be updated.
    string title; // The new title of the task. This field is optional; if the client does not want to update the title, it can be left empty or null.
    string description; // The new description of the task. This field is optional; if the client does not want to update the description, it can be left empty or null.
    string priority; // The new priority of the task. This field is optional; if the client does not want to update the priority, it can be left empty or null.
    string assignee; // The new assignee of the task. This field is optional; if the client does not
    string dueDate; // The new due date of the task. This field is optional; if the client does not want to update the due date, it can be left empty or null.
    UserId updatedBy; // The user who is performing the update operation. This is important for auditing purposes, as it allows the system to track who made changes to the task.
    string[] allowedActions; // The new allowed actions for the task. This field is optional; if the client does not want to update the allowed actions, it can be left empty or null.
    string[string] customAttributes; // The new custom attributes for the task. This field is optional; if the client does not want to update the custom attributes, it can be left empty or
}