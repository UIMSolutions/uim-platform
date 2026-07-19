/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_definition;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:

struct TaskDefinition {
    mixin TenantEntity!(TaskDefinitionId);
    
    TaskProviderId providerId; // The provider that offers this task definition

    string name; // Unique name for the task definition within the tenant
    string description; // Description of the task definition
    TaskCategory category = TaskCategory.approval; // Default category is 'approval'

    string[] allowedActions; // List of allowed actions for tasks created from this definition (e.g., "approve", "reject", "requestChanges")
    string taskSchema; // JSON schema defining the structure of the task's data payload

    bool isActive = true; // Indicates whether this task definition is active and can be used to create tasks
    bool requiresClaim; // Indicates whether tasks created from this definition require claiming before actions can be taken

    Json toJson() const {
        return entityToJson
            .set("providerId", providerId.value)
            .set("name", name)
            .set("description", description)
            .set("category", category.to!string)
            .set("allowedActions", allowedActions.toJson)
            .set("taskSchema", taskSchema)
            .set("isActive", isActive)
            .set("requiresClaim", requiresClaim);
    }
}
