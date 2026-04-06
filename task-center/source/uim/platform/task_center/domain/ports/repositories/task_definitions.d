/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskDefinitionRepository {
    TaskDefinition findById(TaskDefinitionId id);
    TaskDefinition[] findByTenant(TenantId tenantId);
    TaskDefinition[] findByProvider(TaskProviderId providerId);
    TaskDefinition[] findByCategory(TaskCategory category);
    TaskDefinition findByName(string name);
    void save(TaskDefinition entity);
    void update(TaskDefinition entity);
    void remove(TaskDefinitionId id);
}
