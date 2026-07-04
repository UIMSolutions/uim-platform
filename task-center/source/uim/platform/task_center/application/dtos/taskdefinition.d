module uim.platform.task_center.application.dtos.taskdefinition;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
// DTOs for task definitions
// These DTOs are used for creating and updating task definitions. They contain the necessary information for these operations, such as tenant ID, definition ID, provider ID, name, description, category, task schema, and whether the task requires claiming. The create request includes a createdBy field for auditing purposes, while the update request includes an updatedBy field for tracking who made the changes.
struct CreateTaskDefinitionRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task definition belongs, which is important for multi-tenancy support and ensuring that the definition is created in the correct context.
    TaskDefinitionId definitionId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task definition with the same ID already exists, the service can return the existing definition instead of creating a new one. 
    string providerId; // The ID of the provider for the task definition. This is important for identifying the source or owner of the task definition.
    string name; // The name of the task definition. This is a required field, as it provides a human-readable identifier for the task definition.
    string description; // A description of the task definition. This is optional, but it can provide additional context or information about the task definition.
    string category; // The category of the task definition. This is optional, but it can be used to group or classify task definitions.
    string taskSchema; // The schema of the task. This is required, as it defines the structure and rules for the task.
    bool requiresClaim; // Indicates whether the task requires claiming. This is important for workflow and task management purposes.
    UserId createdBy; // The user who is creating the task definition. This is important for auditing purposes, as it allows the system to track who created the task definition.
}

struct UpdateTaskDefinitionRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task definition belongs, which is important for multi-tenancy support and ensuring that the definition is updated in the correct context.
    TaskDefinitionId definitionId; // This is needed to identify which task definition to update. The client must pass the ID of the definition to be updated.
    string providerId; // The new ID of the provider for the task definition. This field is optional; if the client does not want to update the provider, it can be left empty or null.
    string name; // The new name of the task definition. This field is optional; if the client does not want to update the name, it can be left empty or null.
    string description; // The new description of the task definition. This field is optional; if the client does not want to update the description, it can be left empty or null.
    string category; // The new category of the task definition. This field is optional; if the client does not want to update the category, it can be left empty or null.
    string taskSchema; // The new schema of the task. This field is optional; if the client does not want to update the schema, it can be left empty or null.
    bool requiresClaim; // Indicates whether the task requires claiming. This field is optional; if the client does not want to update this, it can be left empty or null.
    UserId updatedBy; // The user who is performing the update operation. This is important for auditing purposes, as it allows the system to track who made changes to the task definition.
}
