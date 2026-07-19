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

    bool existsByName(TenantId tenantId, string name);
    TaskDefinition findByName(TenantId tenantId, string name);
    void removeByName(TenantId tenantId, string name);

    size_t countByProvider(TenantId tenantId, TaskProviderId providerId);
    TaskDefinition[] findByProvider(TenantId tenantId, TaskProviderId providerId);
    void removeByProvider(TenantId tenantId, TaskProviderId providerId);

    size_t countByCategory(TenantId tenantId, TaskCategory category);
    TaskDefinition[] findByCategory(TenantId tenantId, TaskCategory category);
    void removeByCategory(TenantId tenantId, TaskCategory category);

}
