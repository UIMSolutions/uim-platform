/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tasks of workflows: guided processing by people and execution by the
/// automation gateway.
///
/// Rules: tasks change only while their workflow runs (in progress or
/// failed); a task starts when all its dependencies are completed or
/// skipped; a failed task fails the workflow until it is retried or skipped;
/// approvals cannot be skipped; assignees must be known users (if the
/// built-in login has users). Automated and notification tasks are run by
/// runAutomation (background worker, the RunAutomatedTasks action, or
/// inline when the worker is off) in dependency order.
module uim.platform.integration_automation.application.usecases.tasks;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class ProcessTasksUseCase : IaInteractor, IProcessTasks {
  protected IAutomationGateway gateway;

  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy,
    IAutomationGateway gateway) {
    super(repos, clock, events, unitOfWork, policy);
    this.gateway = gateway;
  }

  WorkflowTask get(TenantId t, WorkflowTaskId id) {
    return required(repos.workflowTasks.findById(t, id), "Task '" ~ id.value ~ "'");
  }

  WorkflowTask[] list(TenantId t) {
    return repos.workflowTasks.findAll(t);
  }

  WorkflowTask[] listOf(TenantId t, WorkflowId workflow) {
    return tasksOf(t, workflow);
  }

  WorkflowTask start(TenantId t, WorkflowTaskId id, UserId actor) {
    return transition(t, id, actor, "start", (ref WorkflowTask task, const WorkflowTask[] all) {
      auto open = openDependencies(task, all);
      if (open.length)
        throw IaException.ruleViolation(format("Task '%s' waits for %d unfinished %s (%s)", task.name, open.length,
          open.length == 1 ? "task" : "tasks", open.map!(d => nameOf(all, d)).join(", ")));
      task.start(actor.value, now);
      return Logged("task.started", ExecutionOutcome.info, "Task '" ~ task.name ~ "' started");
    });
  }

  WorkflowTask complete(TenantId t, WorkflowTaskId id, string result, UserId actor) {
    return transition(t, id, actor, "complete", (ref WorkflowTask task, const WorkflowTask[] all) {
      task.complete(result, actor.value, now);
      auto verb = task.taskType == TaskType.approval ? "approved" : "completed";
      return Logged("task." ~ verb, ExecutionOutcome.success, "Task '" ~ task.name ~ "' " ~ verb
        ~ (task.result.length ? ": " ~ task.result : ""), task.durationMs);
    });
  }

  WorkflowTask fail(TenantId t, WorkflowTaskId id, string errorMessage, UserId actor) {
    return transition(t, id, actor, "fail", (ref WorkflowTask task, const WorkflowTask[] all) {
      task.fail(errorMessage, actor.value, now);
      auto verb = task.taskType == TaskType.approval ? "rejected" : "failed";
      return Logged("task." ~ verb, ExecutionOutcome.failure, "Task '" ~ task.name ~ "' " ~ verb ~ ": " ~ task.errorMessage,
        task.durationMs);
    });
  }

  WorkflowTask skip(TenantId t, WorkflowTaskId id, string reason, UserId actor) {
    return transition(t, id, actor, "skip", (ref WorkflowTask task, const WorkflowTask[] all) {
      task.skip(reason, actor.value, now);
      return Logged("task.skipped", ExecutionOutcome.skipped, "Task '" ~ task.name ~ "' skipped: " ~ task.result);
    });
  }

  WorkflowTask retry(TenantId t, WorkflowTaskId id, UserId actor) {
    return transition(t, id, actor, "retry", (ref WorkflowTask task, const WorkflowTask[] all) {
      task.retry();
      return Logged("task.retried", ExecutionOutcome.info, format("Task '%s' set back to pending (attempt %d next)", task.name,
        task.attempts + 1));
    });
  }

  WorkflowTask assign(TenantId t, WorkflowTaskId id, string assignedTo, string priority, UserId actor) {
    auto task = get(t, id);
    if (task.status.isDone)
      throw IaException.ruleViolation("Task '" ~ task.name ~ "' is " ~ cast(string) task.status ~ " and cannot be reassigned");
    auto wf = workflowOf(t, task.workflowId);
    if (!wf.isOpen)
      throw IaException.ruleViolation("Workflow '" ~ wf.id.value ~ "' is " ~ cast(string) wf.status);
    auto user = assignedTo.strip;
    if (user.length) {
      requireId(user, "Assigned user");
      if (repos.users.countAll(t) > 0 && !repos.users.existsById(t, UserAccountId(user)))
        throw IaException.notFound("User '" ~ user ~ "'");
    }
    task.assignedTo = user;
    if (priority.strip.length)
      task.priority = parseDomainEnum!TaskPriority(priority, "priority");
    stampUpdated(task, actor, now);
    batch(() {
      repos.workflowTasks.save(task);
      record(t, task.workflowId, task.id, "task.assigned", ExecutionOutcome.info, user.length
        ? "Task '" ~ task.name ~ "' assigned to " ~ user : "Task '" ~ task.name ~ "' unassigned", actor.value);
    });
    return task;
  }

  AutomationRunSummary runAutomation(TenantId t, UserId actor, WorkflowId only = WorkflowId.init) {
    AutomationRunSummary summary;
    auto workflows = only.isNull ? repos.workflows.findAll(t) : [workflowOf(t, only)];
    foreach (wf; workflows) {
      if (wf.status != WorkflowStatus.inProgress)
        continue;
      summary.workflows++;
      // each execution may make further tasks ready (chains of automated tasks)
      foreach (_; 0 .. 1000) {
        auto current = workflowOf(t, wf.id);
        if (current.status != WorkflowStatus.inProgress)
          break;
        auto ready = readyTasks(tasksOf(t, wf.id)).filter!(x => x.taskType.isMachineTask).array;
        if (ready.length == 0)
          break;
        executeMachineTask(t, current, ready[0], summary);
      }
    }
    return summary;
  }

  // ── internals ───────────────────────────────────────────────────────────

  protected static struct Logged {
    string action;
    ExecutionOutcome outcome;
    string message;
    long durationMs;
  }

  /// Load task + workflow, check the workflow runs, apply the change, save,
  /// log, refresh the workflow progress and run ready automation.
  protected WorkflowTask transition(TenantId t, WorkflowTaskId id, UserId actor, string change,
    scope Logged delegate(ref WorkflowTask, const WorkflowTask[]) @safe apply) {
    auto task = get(t, id);
    auto wf = workflowOf(t, task.workflowId);
    wf.requireRunning(change ~ " task '" ~ task.name ~ "'");
    auto all = tasksOf(t, wf.id);
    auto logged = apply(task, all);
    stampUpdated(task, actor, now);
    batch(() {
      repos.workflowTasks.save(task);
      record(t, wf.id, task.id, logged.action, logged.outcome, logged.message, actor.value, logged.durationMs);
      wf = refreshWorkflow(t, wf, actor);
    });
    if (policy.runAutomationImmediately && wf.status == WorkflowStatus.inProgress) {
      runAutomation(t, actor, wf.id);
      return get(t, id);
    }
    return task;
  }

  protected void executeMachineTask(TenantId t, Workflow wf, WorkflowTask task, ref AutomationRunSummary summary) {
    // claim the task before the (possibly yielding) call: concurrent runs skip it
    task.start(automationActor, now);
    stampUpdated(task, UserId(automationActor), now);
    repos.workflowTasks.save(task);

    AutomationResult r;
    if (task.taskType == TaskType.notification) {
      r = gateway.notify(t, task);
      if (r.success)
        summary.notified++;
    } else {
      summary.executed++;
      r = gateway.execute(requestOf(t, task));
    }

    task = get(t, task.id); // reload: the workflow may have been suspended meanwhile
    if (task.status != TaskStatus.inProgress)
      return;
    auto at = now;
    if (r.success) {
      task.complete(r.message, automationActor, at);
      if (task.taskType == TaskType.automated)
        summary.succeeded++;
    } else {
      task.fail(r.message.length ? r.message : "Automation failed", automationActor, at);
      summary.failed++;
      summary.messages ~= task.name ~ ": " ~ task.errorMessage;
    }
    stampUpdated(task, UserId(automationActor), at);
    batch(() {
      repos.workflowTasks.save(task);
      auto action = task.taskType == TaskType.notification ? (r.success ? "notification.sent" : "notification.failed")
        : (r.success ? "automation.succeeded" : (r.timedOut ? "automation.timedOut" : "automation.failed"));
      record(t, wf.id, task.id, action, r.success ? ExecutionOutcome.success : (r.timedOut ? ExecutionOutcome.timeout
          : ExecutionOutcome.failure), "Task '" ~ task.name ~ "': " ~ (r.success ? task.result : task.errorMessage),
          automationActor, r.durationMs, r.details);
      refreshWorkflow(t, workflowOf(t, wf.id), UserId(automationActor));
    });
  }

  /// Resolve the destination and the effective URL of an automated task.
  protected AutomationRequest requestOf(TenantId t, WorkflowTask task) {
    AutomationRequest r;
    r.tenantId = t;
    r.task = task;
    auto endpoint = task.automationEndpoint.strip;
    if (!task.destinationId.isNull) {
      r.destination = repos.destinations.findById(t, task.destinationId);
      if (!r.destination.isNull) {
        auto base = r.destination.url.stripRight("/");
        r.url = endpoint.length == 0 ? base : isHttpUrl(endpoint) ? endpoint
          : base ~ (endpoint.startsWith("/") ? endpoint : "/" ~ endpoint);
        return r;
      }
    }
    r.url = endpoint;
    return r;
  }

  protected static string nameOf(const WorkflowTask[] all, string id) {
    auto f = all.find!(x => x.id.value == id);
    return f.empty ? id : f.front.name;
  }
}
