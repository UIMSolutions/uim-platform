/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.tasks;

// import uim.platform.datasphere.domain.entities.task;
// import uim.platform.datasphere.domain.ports.repositories.tasks;
// import uim.platform.datasphere.domain.services.task_scheduler;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

interface IManageTasksUseCase { 
  
  UsecaseResult createTask(CreateTaskRequest r);
  DSTask getTask(TenantId tenantId, SpaceId spaceId, TaskId id);
  DSTask[] listTasks(TenantId tenantId, SpaceId spaceId);
  UsecaseResult patchTask(PatchTaskRequest r);
  UsecaseResult deleteTask(TenantId tenantId, SpaceId spaceId, TaskId id);

}
