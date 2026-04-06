/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskRepository {
    Task findById(TaskId id);
    Task[] findByTenant(TenantId tenantId);
    Task[] findByAssignee(string assignee);
    Task[] findByStatus(TaskStatus status);
    Task[] findByProvider(TaskProviderId providerId);
    Task[] findByCategory(TaskCategory category);
    Task[] findByPriority(TaskPriority priority);
    void save(Task entity);
    void update(Task entity);
    void remove(TaskId id);
}
