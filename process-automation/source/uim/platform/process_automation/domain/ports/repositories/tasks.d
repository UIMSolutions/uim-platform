/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.tasks;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.task;

interface TaskRepository : ITenantRepository!(Task, TaskId) {

    size_t countByAssignee(TenantId tenantId, string assignee);
    Task[] findByAssignee(TenantId tenantId, string assignee);
    void removeByAssignee(TenantId tenantId, string assignee);

    size_t countByProcessInstance(ProcessInstanceId instanceId);
    Task[] findByProcessInstance(ProcessInstanceId instanceId);
    void removeByProcessInstance(ProcessInstanceId instanceId);

    size_t countByStatus(TenantId tenantId, TaskStatus status);
    Task[] findByStatus(TenantId tenantId, TaskStatus status);
    void removeByStatus(TenantId tenantId, TaskStatus status);

}
