/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.tasks;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.task;

interface TaskRepository {
    Task findById(TaskId id);
    Task[] findByTenant(TenantId tenantId);
    Task[] findByAssignee(TenantId tenantId, string assignee);
    Task[] findByProcessInstance(ProcessInstanceId instanceId);
    Task[] findByStatus(TenantId tenantId, TaskStatus status);
    void save(Task t);
    void update(Task t);
    void remove(TaskId id);
    long countByTenant(TenantId tenantId);
}
