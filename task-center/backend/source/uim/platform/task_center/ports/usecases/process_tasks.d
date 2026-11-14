/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.usecases.process_tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface IProcessTasks {
  /// claim, release, forward, approve, reject, complete, cancel, escalate,
  /// resubmit — validated by the TaskLifecycle and recorded as TaskAction.
  TaskActionResult perform(PerformTaskActionRequest request);
  TaskAction[] listActions(TenantId tenantId);
  TaskAction getAction(TenantId tenantId, TaskActionId id);
}
