/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.repositories.tasks;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:

class MemoryTaskRepository : TenantRepository!(UIMTask, TaskId), TaskRepository {

    size_t countByAssignee(TenantId tenantId, string assignee) {
        return findByAssignee(tenantId, assignee).length;
    }
    UIMTask[] findByAssignee(TenantId tenantId, string assignee) {
        return findByTenant(tenantId).filter!(t => t.assignee == assignee).array;
    }
    void removeByAssignee(TenantId tenantId, string assignee) {
        findByAssignee(tenantId, assignee).each!(t => remove(t));
    }

    size_t countByStatus(TenantId tenantId, TaskStatus status) {
        return findByStatus(tenantId, status).length;
    }
    UIMTask[] findByStatus(TenantId tenantId, TaskStatus status) {
        return findByTenant(tenantId).filter!(t => t.status == status).array;
    }
    void removeByStatus(TenantId tenantId, TaskStatus status) {
        findByStatus(tenantId, status).each!(t => remove(t));
    }

    size_t countByProvider(TenantId tenantId, TaskProviderId providerId) {
        return findByProvider(tenantId, providerId).length;
    }
    UIMTask[] findByProvider(TenantId tenantId, TaskProviderId providerId) {
        return findByTenant(tenantId).filter!(t => t.providerId == providerId).array;
    }
    void removeByProvider(TenantId tenantId, TaskProviderId providerId) {
        findByProvider(tenantId, providerId).each!(t => remove(t));
    }

    size_t countByCategory(TenantId tenantId, TaskCategory category) {
        return findByCategory(tenantId, category).length;
    }
    UIMTask[] findByCategory(TenantId tenantId, TaskCategory category) {
        return findByTenant(tenantId).filter!(t => t.category == category).array;
    }
    void removeByCategory(TenantId tenantId, TaskCategory category) {
        findByCategory(tenantId, category).each!(t => remove(t));
    }

    size_t countByPriority(TenantId tenantId, TaskPriority priority) {
        return findByPriority(tenantId, priority).length;
    }
    UIMTask[] findByPriority(TenantId tenantId, TaskPriority priority) {
        return findByTenant(tenantId).filter!(t => t.priority == priority).array;
    }
    void removeByPriority(TenantId tenantId, TaskPriority priority) {
        findByPriority(tenantId, priority).each!(t => remove(t));
    }

}
