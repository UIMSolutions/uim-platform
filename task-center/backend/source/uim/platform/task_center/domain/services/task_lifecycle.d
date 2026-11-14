/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The task state machine (pure, no I/O).
///
///   open / reserved / forwarded ──claim──▶ inProgress ──release──▶ open
///   any non-final ──forward(to)──▶ forwarded            (claim is dropped)
///   any non-final ──approve / reject / complete──▶ completed (outcome set)
///   any non-final ──cancel──▶ cancelled
///   any non-final ──escalate──▶ same status, priority + 1
///   completed / cancelled / failed ──resubmit──▶ open   (outcome cleared)
///
/// Rules: approve/reject need an approval or review task (or an explicit
/// allowedActions entry); a non-empty allowedActions list restricts
/// approve, reject, complete, cancel, escalate and resubmit; definitions with
/// requiresClaim accept decisions only from the claimer; only the claimer
/// may release; a task claimed by someone else cannot be claimed.
module uim.platform.task_center.domain.services.task_lifecycle;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Input of a transition besides the task itself.
struct ActionInput {
  string actor; /// user performing the action
  string forwardTo; /// forward: new recipient
  bool requiresClaim; /// from the task definition
  long now; /// std time
}

/// Throw unless the action is possible right now (does not modify the task).
void checkAction(const ref UIMTask task, ActionType action, const ActionInput input) {
  auto title = "Task '" ~ task.title ~ "'";
  if (input.actor.strip.length == 0)
    throw TaskCenterException.invalid("An actor is required to process tasks");
  if (!task.allows(action))
    throw TaskCenterException.ruleViolation(title ~ " does not allow '" ~ cast(string) action ~ "' (allowed: "
        ~ task.allowedActions.join(", ") ~ ")");

  if (action == ActionType.resubmit) {
    if (!task.isFinished)
      throw TaskCenterException.ruleViolation(title ~ " is " ~ cast(string) task.status ~ "; only finished tasks can be resubmitted");
    return;
  }
  if (task.isFinished)
    throw TaskCenterException.ruleViolation(title ~ " is already " ~ cast(string) task.status);

  final switch (action) {
  case ActionType.claim:
    if (task.isClaimed)
      throw TaskCenterException.conflict(title ~ " is already claimed by " ~ task.claimedBy);
    if (task.assignee.length > 0 && task.assignee != input.actor && task.status == TaskStatus.reserved)
      throw TaskCenterException.forbidden(title ~ " is reserved for " ~ task.assignee);
    break;
  case ActionType.release:
    if (!task.isClaimed)
      throw TaskCenterException.ruleViolation(title ~ " is not claimed");
    if (task.claimedBy != input.actor)
      throw TaskCenterException.forbidden(title ~ " can only be released by " ~ task.claimedBy);
    break;
  case ActionType.forward:
    if (input.forwardTo.strip.length == 0)
      throw TaskCenterException.invalid("forward needs a recipient (forwardTo)");
    if (input.forwardTo == task.assignee)
      throw TaskCenterException.ruleViolation(title ~ " is already assigned to " ~ task.assignee);
    if (task.isClaimed && task.claimedBy != input.actor)
      throw TaskCenterException.forbidden(title ~ " is claimed by " ~ task.claimedBy);
    break;
  case ActionType.approve, ActionType.reject:
    if (task.allowedActions.length == 0 && task.category != TaskCategory.approval && task.category != TaskCategory.review)
      throw TaskCenterException.ruleViolation(title ~ " is a " ~ cast(string) task.category ~ " task and cannot be "
          ~ (action == ActionType.approve ? "approved" : "rejected"));
    checkDecision(task, input, title);
    break;
  case ActionType.complete:
    checkDecision(task, input, title);
    break;
  case ActionType.cancel:
    if (task.isClaimed && task.claimedBy != input.actor)
      throw TaskCenterException.forbidden(title ~ " is claimed by " ~ task.claimedBy);
    break;
  case ActionType.escalate:
    if (task.priority == TaskPriority.veryHigh)
      throw TaskCenterException.ruleViolation(title ~ " already has the highest priority");
    break;
  case ActionType.resubmit:
    break; // handled above
  }
}

private void checkDecision(const ref UIMTask task, const ActionInput input, string title) {
  if (task.isClaimed && task.claimedBy != input.actor)
    throw TaskCenterException.forbidden(title ~ " is claimed by " ~ task.claimedBy);
  if (input.requiresClaim && !task.isClaimed)
    throw TaskCenterException.ruleViolation(title ~ " must be claimed before a decision");
}

/// Perform the transition in place. Returns the status before the action.
TaskStatus applyAction(ref UIMTask task, ActionType action, const ActionInput input) {
  checkAction(task, action, input);
  auto from = task.status;
  final switch (action) {
  case ActionType.claim:
    task.isClaimed = true;
    task.claimedBy = input.actor;
    task.processor = input.actor;
    task.status = TaskStatus.inProgress;
    break;
  case ActionType.release:
    dropClaim(task);
    task.status = TaskStatus.open;
    break;
  case ActionType.forward:
    dropClaim(task);
    task.assignee = input.forwardTo.strip;
    task.status = TaskStatus.forwarded;
    break;
  case ActionType.approve:
    finish(task, TaskStatus.completed, TaskOutcome.approved, input);
    break;
  case ActionType.reject:
    finish(task, TaskStatus.completed, TaskOutcome.rejected, input);
    break;
  case ActionType.complete:
    finish(task, TaskStatus.completed, TaskOutcome.completed, input);
    break;
  case ActionType.cancel:
    finish(task, TaskStatus.cancelled, TaskOutcome.cancelled, input);
    break;
  case ActionType.escalate:
    task.priority = escalated(task.priority);
    break;
  case ActionType.resubmit:
    dropClaim(task);
    task.status = TaskStatus.open;
    task.outcome = TaskOutcome.none;
    task.completedAt = 0;
    break;
  }
  return from;
}

/// Actions the actor may perform now (drives the Fiori buttons).
ActionType[] availableActions(const ref UIMTask task, string actor, bool requiresClaim) {
  import std.traits : EnumMembers;

  ActionType[] result;
  auto input = ActionInput(actor, "\x01", requiresClaim, 0); // placeholder recipient for forward
  static foreach (a; EnumMembers!ActionType) {
    try {
      checkAction(task, a, input);
      result ~= a;
    } catch (TaskCenterException) {
    }
  }
  return result;
}

/// The next priority (veryHigh stays veryHigh).
TaskPriority escalated(TaskPriority p) pure nothrow {
  final switch (p) {
  case TaskPriority.low:
    return TaskPriority.medium;
  case TaskPriority.medium:
    return TaskPriority.high;
  case TaskPriority.high, TaskPriority.veryHigh:
    return TaskPriority.veryHigh;
  }
}

private void dropClaim(ref UIMTask task) {
  task.isClaimed = false;
  task.claimedBy = "";
  task.processor = "";
}

private void finish(ref UIMTask task, TaskStatus status, TaskOutcome outcome, const ActionInput input) {
  task.status = status;
  task.outcome = outcome;
  task.processor = input.actor;
  task.isClaimed = false;
  task.completedAt = input.now;
}

///
unittest {
  UIMTask t;
  t.title = "Approve PO";
  t.category = TaskCategory.approval;
  auto anna = ActionInput("anna"), ben = ActionInput("ben");

  assert(applyAction(t, ActionType.claim, anna) == TaskStatus.open);
  assert(t.status == TaskStatus.inProgress && t.claimedBy == "anna");
  assert(failsWith(TaskCenterErrorKind.conflict, () { applyAction(t, ActionType.claim, ben); }));
  assert(failsWith(TaskCenterErrorKind.forbidden, () { applyAction(t, ActionType.release, ben); }));
  assert(failsWith(TaskCenterErrorKind.forbidden, () { applyAction(t, ActionType.approve, ben); }));
  assert(availableActions(t, "ben", false) == [ActionType.escalate]);

  applyAction(t, ActionType.escalate, anna);
  assert(t.priority == TaskPriority.high);
  applyAction(t, ActionType.approve, ActionInput("anna", "", false, 42));
  assert(t.status == TaskStatus.completed && t.outcome == TaskOutcome.approved && t.completedAt == 42 && !t.isClaimed);
  assert(failsWith(TaskCenterErrorKind.ruleViolation, () { applyAction(t, ActionType.cancel, anna); }));
  assert(availableActions(t, "anna", false) == [ActionType.resubmit]);

  applyAction(t, ActionType.resubmit, ben);
  assert(t.status == TaskStatus.open && t.outcome == TaskOutcome.none && t.completedAt == 0);

  // forward drops the claim; decisions may need a claim
  applyAction(t, ActionType.claim, anna);
  assert(failsWith(TaskCenterErrorKind.invalid, () { applyAction(t, ActionType.forward, anna); }));
  applyAction(t, ActionType.forward, ActionInput("anna", "carl"));
  assert(t.status == TaskStatus.forwarded && t.assignee == "carl" && !t.isClaimed);
  assert(failsWith(TaskCenterErrorKind.ruleViolation, () { applyAction(t, ActionType.reject, ActionInput("carl", "", true)); }));

  // allowedActions / category restrictions
  UIMTask todo;
  todo.title = "Read policy";
  todo.category = TaskCategory.toDoItem;
  assert(failsWith(TaskCenterErrorKind.ruleViolation, () { applyAction(todo, ActionType.approve, anna); }));
  todo.allowedActions = ["complete"];
  assert(failsWith(TaskCenterErrorKind.ruleViolation, () { applyAction(todo, ActionType.cancel, anna); }));
  applyAction(todo, ActionType.complete, anna);
  assert(todo.outcome == TaskOutcome.completed);

  // reserved tasks belong to their assignee
  UIMTask reserved;
  reserved.title = "Reserved";
  reserved.status = TaskStatus.reserved;
  reserved.assignee = "anna";
  assert(failsWith(TaskCenterErrorKind.forbidden, () { applyAction(reserved, ActionType.claim, ben); }));
  applyAction(reserved, ActionType.claim, anna);
  assert(escalated(TaskPriority.veryHigh) == TaskPriority.veryHigh);
}
