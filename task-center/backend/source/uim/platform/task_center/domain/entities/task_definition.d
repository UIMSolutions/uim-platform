/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A task type: category, default priority, SLA and the actions its tasks allow.
module uim.platform.task_center.domain.entities.task_definition;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskDefinition {
  mixin TenantEntity!TaskDefinitionId;

  TaskProviderId providerId; /// provider that offers this definition (optional)
  string name; /// unique per tenant
  string description;
  TaskCategory category = TaskCategory.approval;
  TaskPriority defaultPriority = TaskPriority.medium;
  string[] allowedActions; /// copied to new tasks
  string taskSchema; /// JSON schema of the task's custom attributes (informational)
  int dueInDays; /// SLA: default dueDate = creation day + dueInDays (0 = none)
  bool isActive = true; /// inactive definitions accept no new tasks
  bool requiresClaim; /// decisions only by the claimer

  void validate() const {
    requireText(name, "Task definition name");
    validateActionNames(allowedActions);
    requireNonNegative(dueInDays, "dueInDays");
    if (dueInDays > 3650)
      throw TaskCenterException.invalid("dueInDays must not exceed 3650");
  }
}

///
unittest {
  TaskDefinition d;
  d.name = "Purchase Order Approval";
  d.allowedActions = ["approve", "reject"];
  d.validate();
  d.dueInDays = -1;
  assert(failsWith(TaskCenterErrorKind.invalid, () { d.validate(); }));
}
