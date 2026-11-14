/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.usecases.manage_task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface IManageTaskDefinitions {
  TaskDefinition[] listTaskDefinitions(TenantId tenantId);
  TaskDefinition getTaskDefinition(TenantId tenantId, TaskDefinitionId id);
  TaskDefinition createTaskDefinition(CreateTaskDefinitionRequest request);
  TaskDefinition updateTaskDefinition(UpdateTaskDefinitionRequest request);
  /// Refused while unfinished tasks use the definition.
  void deleteTaskDefinition(TenantId tenantId, TaskDefinitionId id);
}
