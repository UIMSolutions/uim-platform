/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskRepository : ITenantRepository!(Task, TaskId) {

    size_t countByAssignee(string assignee);
    Task[] findByAssignee(string assignee);
    void removeByAssignee(string assignee);

    size_t countByStatus(TaskStatus status);
    Task[] findByStatus(TaskStatus status);
    void removeByStatus(TaskStatus status);

    size_t countByProvider(TaskProviderId providerId);    
    Task[] findByProvider(TaskProviderId providerId);
    void removeByProvider(TaskProviderId providerId);

    size_t countByCategory(TaskCategory category);
    Task[] findByCategory(TaskCategory category);
    void removeByCategory(TaskCategory category);

    size_t countByPriority(TaskPriority priority);
    Task[] findByPriority(TaskPriority priority);
    void removeByPriority(TaskPriority priority);

}
