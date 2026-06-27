/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_definitions;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class MemoryTaskDefinitionRepository : TentRepository!(TaskDefinition, TaskDefinitionId), TaskDefinitionRepository {

    bool existsByName(TenantId tenantId, string name) {
        return findByName(tenantId, name).id != TaskDefinitionId.init;
    }

    TaskDefinition findByName(TenantId tenantId, string name) {
        foreach (d; findByTenant(tenantId))
            if (d.name == name)
                return d;
                
        return TaskDefinition.init;
    }

    void removeByName(TenantId tenantId, string name) {
        foreach (d; findByTenant(tenantId))
            if (d.name == name)
                remove(d);
    }

    // #region ByProvider
    size_t countByProvider(TenantId tenantId, TaskProviderId providerId) {
        return findByProvider(tenantId, providerId).length;
    }

    TaskDefinition[] filterByProvider(TaskDefinition[] definitions, TaskProviderId providerId) {
        return definitions.filter!(d => d.providerId == providerId).array;
    }

    TaskDefinition[] findByProvider(TenantId tenantId, TaskProviderId providerId) {
        return filterByProvider(findByTenant(tenantId), providerId);
    }

    void removeByProvider(TenantId tenantId, TaskProviderId providerId) {
        findByProvider(tenantId, providerId).each!(d => remove(d));
    }

    // #region ByCategory
    size_t countByCategory(TenantId tenantId, TaskCategory category) {
        return findByCategory(tenantId, category).length;
    }

    TaskDefinition[] filterByCategory(TaskDefinition[] definitions, TaskCategory category) {
        return definitions.filter!(d => d.category == category).array;
    }

    TaskDefinition[] findByCategory(TenantId tenantId, TaskCategory category) {
        return filterByCategory(findByTenant(tenantId), category);
    }

    void removeByCategory(TenantId tenantId, TaskCategory category) {
        findByCategory(tenantId, category).each!(d => remove(d));
    }
    // #endregion ByCategory

    // #region ByPriority
    // size_t countByPriority(TenantId tenantId, TaskPriority priority) {
    //     return findByPriority(tenantId, priority).length;
    // }

    // TaskDefinition[] filterByPriority(TaskDefinition[] definitions, TaskPriority priority) {
    //     return definitions.filter!(d => d.priority == priority).array;
    // }

    // TaskDefinition[] findByPriority(TenantId tenantId, TaskPriority priority) {
    //     return filterByPriority(findByTenant(tenantId), priority);
    // }

    // void removeByPriority(TenantId tenantId, TaskPriority priority) {
    //     findByPriority(tenantId, priority).each!(d => remove(d));
    // }
    // #endregion ByPriority

}
