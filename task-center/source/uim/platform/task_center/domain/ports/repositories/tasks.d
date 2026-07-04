/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskRepository : ITenantRepository!(UIMTask, TaskId) {

    size_t countByAssignee(TenantId tenantId, string assignee);
    UIMTask[] findByAssignee(TenantId tenantId, string assignee);
    void removeByAssignee(TenantId tenantId, string assignee);

    size_t countByStatus(TenantId tenantId, TaskStatus status);
    UIMTask[] findByStatus(TenantId tenantId, TaskStatus status);
    void removeByStatus(TenantId tenantId, TaskStatus status);

    size_t countByProvider(TenantId tenantId, TaskProviderId providerId);    
    UIMTask[] findByProvider(TenantId tenantId, TaskProviderId providerId);
    void removeByProvider(TenantId tenantId, TaskProviderId providerId);

    size_t countByCategory(TenantId tenantId, TaskCategory category);
    UIMTask[] findByCategory(TenantId tenantId, TaskCategory category);
    void removeByCategory(TenantId tenantId, TaskCategory category);

    size_t countByPriority(TenantId tenantId, TaskPriority priority);
    UIMTask[] findByPriority(TenantId tenantId, TaskPriority priority);
    void removeByPriority(TenantId tenantId, TaskPriority priority);

}
