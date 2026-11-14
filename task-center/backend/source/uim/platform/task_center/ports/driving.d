/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData, CLI, GUI, workers) may call.
module uim.platform.task_center.ports.driving;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskCenterPorts {
  IManageTasks tasks;
  IProcessTasks processing;
  IManageTaskDefinitions definitions;
  IManageTaskProviders providers;
  ISyncTaskProviders sync;
  IManageTaskComments comments;
  IManageTaskAttachments attachments;
  IManageSubstitutionRules substitutions;
  IManageUserTaskFilters filters;
  ITaskCenterStatistics statistics;
}
