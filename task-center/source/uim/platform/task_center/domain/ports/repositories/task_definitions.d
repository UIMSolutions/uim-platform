/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskDefinitionRepository : ITenantRepository!(TaskDefinition, TaskDefinitionId) {

    bool existsByName(string name);
    TaskDefinition findByName(string name);
    void removeByName(string name);

    size_t countByProvider(TaskProviderId providerId);
    TaskDefinition[] findByProvider(TaskProviderId providerId);
    void removeByProvider(TaskProviderId providerId);

    size_t countByCategory(TaskCategory category);
    TaskDefinition[] findByCategory(TaskCategory category);
    void removeByCategory(TaskCategory category);

}
