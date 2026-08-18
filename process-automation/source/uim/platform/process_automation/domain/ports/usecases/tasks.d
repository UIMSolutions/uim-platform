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

    UsecaseResult createTask(CreateTaskRequest r);
    PATask getTask(TenantId tenantId, TaskId id);
    PATask[] listTasks(TenantId tenantId);
    PATask[] listTasksByAssignee(TenantId tenantId, string assignee);
    PATask[] listTasksByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId);
    UsecaseResult claimTask(ClaimTaskRequest r);
    UsecaseResult completeTask(CompleteTaskRequest r);
    UsecaseResult updateTask(UpdateTaskRequest r);
    UsecaseResult deleteTask(TenantId tenantId, TaskId taskId);

}
