/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.process_tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ProcessTasksUseCase : IProcessTasks {
  protected ITaskRepository tasks;
  protected ITaskDefinitionRepository definitions;
  protected ISubstitutionRuleRepository substitutions;
  protected ITaskActionRepository actions;
  protected ITaskCommentRepository comments;
  protected ITaskEventPublisher events;

  this(ITaskRepository tasks, ITaskDefinitionRepository definitions, ISubstitutionRuleRepository substitutions,
    ITaskActionRepository actions, ITaskCommentRepository comments, ITaskEventPublisher events) {
    this.tasks = tasks;
    this.definitions = definitions;
    this.substitutions = substitutions;
    this.actions = actions;
    this.comments = comments;
    this.events = events;
  }

  TaskActionResult perform(PerformTaskActionRequest r) {
    auto action = parseDomainEnum!ActionType(r.action, "action");
    auto task = tasks.findById(r.tenantId, r.taskId).required("Task '" ~ r.taskId.value ~ "'");
    bool requiresClaim;
    if (!task.definitionId.isNull) {
      auto def = definitions.findById(r.tenantId, task.definitionId);
      requiresClaim = !def.isNull && def.requiresClaim;
    }

    auto now = nowStdTime();
    auto from = applyAction(task, action, ActionInput(r.actor.value, r.forwardTo, requiresClaim, now));
    if (action == ActionType.forward) {
      // forwarding to an absent user honours their auto-forward rule
      auto recipient = resolveRecipient(substitutions.findAll(r.tenantId), task.assignee, task.definitionId, todayIso());
      task.assignee = recipient.assignee;
      task.substitutedFor = recipient.substitutedFor;
    }
    stampUpdated(task, r.actor);
    tasks.save(task);

    TaskAction a;
    stampCreated!(TaskAction, TaskActionId)(a, r.tenantId, r.actor, "");
    a.taskId = task.id;
    a.actionType = action;
    a.performedBy = r.actor.value;
    a.performedAt = now;
    a.forwardTo = action == ActionType.forward ? task.assignee : "";
    a.comment = r.comment;
    a.fromStatus = from;
    a.toStatus = task.status;
    actions.save(a);

    if (r.comment.strip.length > 0) {
      TaskComment c;
      stampCreated!(TaskComment, TaskCommentId)(c, r.tenantId, r.actor, "");
      c.taskId = task.id;
      c.author = r.actor.value;
      c.content = r.comment.strip;
      c.validate();
      comments.save(c);
    }

    publishTaskEvent(events, task, pastTense(action), r.actor.value, Json([
        "from": Json(cast(string) from), "to": Json(cast(string) task.status), "outcome": Json(cast(string) task.outcome),
        "assignee": Json(task.assignee)
      ]));
    return TaskActionResult(task, a);
  }

  TaskAction[] listActions(TenantId tenantId) {
    return actions.findAll(tenantId);
  }

  TaskAction getAction(TenantId tenantId, TaskActionId id) {
    return actions.findById(tenantId, id).required("Task action '" ~ id.value ~ "'");
  }
}

/// Event step of an action: claim → "claimed", resubmit → "resubmitted", …
string pastTense(ActionType a) pure nothrow {
  final switch (a) {
  case ActionType.claim:
    return "claimed";
  case ActionType.release:
    return "released";
  case ActionType.forward:
    return "forwarded";
  case ActionType.approve:
    return "approved";
  case ActionType.reject:
    return "rejected";
  case ActionType.complete:
    return "completed";
  case ActionType.cancel:
    return "cancelled";
  case ActionType.escalate:
    return "escalated";
  case ActionType.resubmit:
    return "resubmitted";
  }
}
