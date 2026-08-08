/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.tasks;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageTasksUseCase { 

    CommandResult createTask(CreateTaskRequest r);
    PATask getTask(TenantId tenantId, TaskId id);
    PATask[] listTasks(TenantId tenantId);
    PATask[] listTasksByAssignee(TenantId tenantId, string assignee);
    PATask[] listTasksByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId);
    CommandResult claimTask(ClaimTaskRequest r);
    CommandResult completeTask(CompleteTaskRequest r);
    CommandResult updateTask(UpdateTaskRequest r);
    CommandResult deleteTask(TenantId tenantId, TaskId taskId);

}
