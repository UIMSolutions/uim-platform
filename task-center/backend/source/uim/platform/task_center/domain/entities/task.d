/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A task of the unified inbox — created locally (API) or federated from a
/// task provider. Its status only changes through actions (TaskLifecycle).
module uim.platform.task_center.domain.entities.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct UIMTask {
  mixin TenantEntity!TaskId;

  TaskDefinitionId definitionId; /// template the task was created from (optional)
  TaskProviderId providerId; /// provider the task was federated from (optional)
  string externalTaskId; /// id of the task in the provider system (unique per provider)

  string title;
  string description;
  TaskStatus status = TaskStatus.open;
  TaskPriority priority = TaskPriority.medium;
  TaskCategory category = TaskCategory.approval;
  TaskOutcome outcome = TaskOutcome.none;

  string assignee; /// current recipient ("" = unassigned, anyone may claim)
  string substitutedFor; /// original recipient if a substitution rule forwarded the task
  string creator;
  string processor; /// user working on the task (the claimer)
  string sourceApplication;

  string[] allowedActions; /// restricts the restrictable actions (empty = all)
  string customAttributes; /// provider specific attributes as JSON object text

  bool isClaimed;
  string claimedBy;

  string dueDate; /// ISO date ("YYYY-MM-DD"), "" = no deadline
  long completedAt; /// std time, 0 = open

  bool isFinished() const {
    return status.isFinal;
  }

  /// Due before today and still open.
  bool isOverdue(string today) const {
    return !isFinished && dueDate.length > 0 && dueDate < today;
  }

  bool allows(ActionType action) const {
    return !action.isRestrictable || allowedActions.length == 0 || allowedActions.canFind(cast(string) action);
  }

  void validate() const {
    requireText(title, "Task title");
    if (title.length > 500)
      throw TaskCenterException.invalid("Task title exceeds 500 characters");
    requireOptionalDate(dueDate, "dueDate");
    validateActionNames(allowedActions);
    validateAttributes(customAttributes);
    if (externalTaskId.length > 0 && providerId.isNull)
      throw TaskCenterException.invalid("externalTaskId needs a providerId");
  }
}

/// Every entry must be an ActionType.
void validateActionNames(const string[] names) {
  foreach (n; names)
    parseDomainEnum!ActionType(n, "allowedActions entry");
}

/// "" or a JSON object (custom attributes).
void validateAttributes(string text) @trusted {
  if (text.strip.length == 0)
    return;
  Json j;
  try
    j = parseJsonString(text);
  catch (Exception e)
    throw TaskCenterException.invalid("customAttributes must be a JSON object: " ~ e.msg);
  if (j.type != Json.Type.object)
    throw TaskCenterException.invalid("customAttributes must be a JSON object");
}

///
unittest {
  UIMTask t;
  t.title = "Approve PO 4711";
  t.dueDate = "2026-01-10";
  t.validate();
  assert(t.isOverdue("2026-01-11") && !t.isOverdue("2026-01-10"));
  t.allowedActions = ["approve", "reject"];
  assert(t.allows(ActionType.approve) && !t.allows(ActionType.complete) && t.allows(ActionType.claim));
  t.allowedActions = ["approve", "dance"];
  assert(failsWith(TaskCenterErrorKind.invalid, () { t.validate(); }));
  t.allowedActions = null;
  t.customAttributes = "[1]";
  assert(failsWith(TaskCenterErrorKind.invalid, () { t.validate(); }));
  t.customAttributes = `{"amount": "1200 EUR"}`;
  t.externalTaskId = "X1";
  assert(failsWith(TaskCenterErrorKind.invalid, () { t.validate(); })); // no provider
}
