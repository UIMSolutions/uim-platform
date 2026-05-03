/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskDefinitionRepository : TenantRepository!(TaskDefinition, TaskDefinitionId), TaskDefinitionRepository {

    size_t countByProvider(TenantId tenantId, string providerId) {
        return findByProvider(tenantId, providerId).length;
    }

    TaskDefinition[] findByProvider(TenantId tenantId, string providerId) {
        return findByTenant(tenantId).filter!(d => d.providerId == providerId).array;
    }

    void removeByProvider(TenantId tenantId, string providerId) {
        findByProvider(tenantId, providerId).each!(d => remove(d));
    }

    size_t countByCategory(TenantId tenantId, TaskCategory category) {
        return findByCategory(tenantId, category).length;
    }

    TaskDefinition[] findByCategory(TenantId tenantId, TaskCategory category) {
        return findByTenant(tenantId).filter!(d => d.category == category).array;
    }

    void removeByCategory(TenantId tenantId, TaskCategory category) {
        findByCategory(tenantId, category).each!(d => remove(d));
    }

    size_t countByPriority(TenantId tenantId, TaskPriority priority) {
        return findByPriority(tenantId, priority).length;
    }

    TaskDefinition[] findByPriority(TenantId tenantId, TaskPriority priority) {
        return findByTenant(tenantId).filter!(d => d.priority == priority).array;
    }

    void removeByPriority(TenantId tenantId, TaskPriority priority) {
        findByPriority(tenantId, priority).each!(d => remove(d));
    }

}
