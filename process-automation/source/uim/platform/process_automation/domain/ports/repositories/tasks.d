/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.tasks;
// import uim.platform.process_automation.domain.types;
// import uim.platform.process_automation.domain.entities.task;
import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
interface TaskRepository : ITenantRepository!(PATask, TaskId) {

    size_t countByAssignee(TenantId tenantId, UserId assignee);
    PATask[] findByAssignee(TenantId tenantId, UserId assignee);
    void removeByAssignee(TenantId tenantId, UserId assignee);

    size_t countByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId);
    PATask[] findByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId);
    void removeByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId);

    size_t countByStatus(TenantId tenantId, TaskStatus status);
    PATask[] findByStatus(TenantId tenantId, TaskStatus status);
    void removeByStatus(TenantId tenantId, TaskStatus status);

}
