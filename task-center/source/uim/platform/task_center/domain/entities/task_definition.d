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
    
    TaskProviderId providerId;

    string name;
    string description;
    TaskCategory category = TaskCategory.approval;

    string[] allowedActions;
    string taskSchema;

    bool isActive = true;
    bool requiresClaim;

    Json toJson() const {
        return entityToJson
            .set("providerId", providerId.value)
            .set("name", name)
            .set("description", description)
            .set("category", category.to!string)
            .set("allowedActions", allowedActions)
            .set("taskSchema", taskSchema)
            .set("isActive", isActive)
            .set("requiresClaim", requiresClaim);
    }
}
