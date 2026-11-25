/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Workflows (instances of a scenario) and their tasks. The state machines
/// of both live here; the WorkflowEngine domain service derives progress
/// and readiness from the task list.
///
///   Workflow  planned → inProgress ⇄ suspended
///                         ↓   ↑ retry/skip
///                       failed
///             inProgress → completed (every task done)
///             any open   → terminated
///
///   Task      pending → inProgress → completed | failed
///             pending | failed → skipped (not approvals)
///             failed → pending (retry)
module uim.platform.integration_automation.domain.entities.workflow;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct Workflow {
  mixin TenantEntity!WorkflowId;

  ScenarioId scenarioId;
  string scenarioVersion;
  string name;
  string description;
  WorkflowStatus status = WorkflowStatus.planned;
  SystemConnectionId sourceSystemId;
  SystemConnectionId targetSystemId;
  int totalTasks;
  int completedTasks; /// completed or skipped
  int failedTasks;
  int progressPercent;
  WorkflowTaskId currentTaskId; /// first ready task (by sequence number)
  long startedAt;
  long completedAt;
  string terminationReason;

  bool isOpen() const {
    return status.isOpen;
  }

  /// Tasks may only change while the workflow runs.
  void requireRunning(string change) const {
    if (status != WorkflowStatus.inProgress && status != WorkflowStatus.failed)
      throw IaException.ruleViolation("Workflow '" ~ id.value ~ "' is " ~ cast(string) status ~ " — cannot " ~ change);
  }

  void start(long at) {
    if (status != WorkflowStatus.planned)
      throw IaException.ruleViolation("Workflow '" ~ id.value ~ "' is " ~ cast(string) status ~ ", not planned");
    status = WorkflowStatus.inProgress;
    startedAt = at;
  }

  void suspend() {
    if (status != WorkflowStatus.inProgress && status != WorkflowStatus.failed)
      throw IaException.ruleViolation("Only running workflows can be suspended");
    status = WorkflowStatus.suspended;
  }

  void resume() {
    if (status != WorkflowStatus.suspended)
      throw IaException.ruleViolation("Workflow '" ~ id.value ~ "' is not suspended");
    status = failedTasks > 0 ? WorkflowStatus.failed : WorkflowStatus.inProgress;
  }

  void terminate(string reason, long at) {
    if (!isOpen)
      throw IaException.ruleViolation("Workflow '" ~ id.value ~ "' is already " ~ cast(string) status);
    status = WorkflowStatus.terminated;
    terminationReason = reason.strip;
    completedAt = at;
  }

  /// Take over the progress of the task list; running workflows complete
  /// when every task is done and fail while a task failed.
  void apply(const WorkflowProgress p, long at) {
    totalTasks = p.total;
    completedTasks = p.done;
    failedTasks = p.failed;
    progressPercent = p.percent;
    currentTaskId = p.current;
    if (status == WorkflowStatus.inProgress || status == WorkflowStatus.failed) {
      if (p.total > 0 && p.done == p.total) {
        status = WorkflowStatus.completed;
        completedAt = at;
      } else
        status = p.failed > 0 ? WorkflowStatus.failed : WorkflowStatus.inProgress;
    }
  }

  void validate() const {
    requireId(id.value, "Workflow ID");
    if (scenarioId.isNull)
      throw IaException.invalid("Scenario is required");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 4000, "Description");
    requireMaxLength(terminationReason, 2000, "Termination reason");
  }
}

struct WorkflowTask {
  mixin TenantEntity!WorkflowTaskId;

  WorkflowId workflowId;
  ScenarioTaskId templateId;
  int sequenceNumber;
  string name;
  string description;
  TaskType taskType = TaskType.manual;
  TaskStatus status = TaskStatus.pending;
  TaskPriority priority = TaskPriority.medium;
  string assignedTo; /// user id of the processor ("" = anyone with the role)
  string assignedRole;
  string instructions;
  DestinationId destinationId;
  string automationEndpoint;
  string automationPayload;
  SystemConnectionId sourceSystemId;
  SystemConnectionId targetSystemId;
  string[] dependsOn; /// ids of tasks of the same workflow
  string result;
  string errorMessage;
  string processedBy;
  int attempts; /// starts (incl. automated runs)
  int estimatedMinutes;
  long startedAt;
  long completedAt;

  void start(string actor, long at) {
    if (status != TaskStatus.pending)
      throw IaException.ruleViolation("Task '" ~ id.value ~ "' is " ~ cast(string) status ~ ", not pending");
    status = TaskStatus.inProgress;
    processedBy = actor;
    startedAt = at;
    completedAt = 0;
    errorMessage = "";
    attempts++;
  }

  void complete(string resultText, string actor, long at) {
    if (status != TaskStatus.inProgress)
      throw IaException.ruleViolation("Task '" ~ id.value ~ "' is " ~ cast(string) status ~ " — start it first");
    status = TaskStatus.completed;
    result = resultText.strip;
    processedBy = actor;
    completedAt = at;
  }

  void fail(string message, string actor, long at) {
    if (status != TaskStatus.inProgress && status != TaskStatus.pending)
      throw IaException.ruleViolation("Task '" ~ id.value ~ "' is " ~ cast(string) status ~ " and cannot fail");
    if (message.strip.length == 0)
      throw IaException.invalid("An error message is required");
    status = TaskStatus.failed;
    errorMessage = message.strip;
    processedBy = actor;
    completedAt = at;
  }

  void skip(string reason, string actor, long at) {
    if (taskType == TaskType.approval)
      throw IaException.ruleViolation("Approval task '" ~ id.value ~ "' cannot be skipped — approve or reject it");
    if (status != TaskStatus.pending && status != TaskStatus.failed)
      throw IaException.ruleViolation("Task '" ~ id.value ~ "' is " ~ cast(string) status ~ " and cannot be skipped");
    if (reason.strip.length == 0)
      throw IaException.invalid("A reason is required to skip a task");
    status = TaskStatus.skipped;
    result = reason.strip;
    processedBy = actor;
    completedAt = at;
  }

  void retry() {
    if (status != TaskStatus.failed)
      throw IaException.ruleViolation("Only failed tasks can be retried");
    status = TaskStatus.pending;
    errorMessage = "";
    completedAt = 0;
  }

  /// Duration of the last processing in milliseconds.
  long durationMs() const {
    return millisBetween(startedAt, completedAt);
  }

  void validate() const {
    requireId(id.value, "Task ID");
    if (workflowId.isNull)
      throw IaException.invalid("Workflow is required");
    requireText(name, "Name");
    if (assignedTo.length)
      requireId(assignedTo, "Assigned user");
    requireMaxLength(result, 20_000, "Result");
    requireMaxLength(errorMessage, 20_000, "Error message");
  }
}

///
unittest {
  Workflow wf;
  wf.id = WorkflowId("wf");
  wf.scenarioId = ScenarioId("s");
  wf.name = "Run";
  wf.validate();
  assert(failsWith(IaErrorKind.ruleViolation, () { wf.resume(); }));
  wf.start(1);
  wf.suspend();
  assert(failsWith(IaErrorKind.ruleViolation, () { wf.requireRunning("start a task"); }));
  wf.resume();
  WorkflowProgress p;
  p.total = 2;
  p.done = 1;
  p.failed = 1;
  wf.apply(p, 2);
  assert(wf.status == WorkflowStatus.failed);
  p.failed = 0;
  p.done = 2;
  wf.apply(p, 3);
  assert(wf.status == WorkflowStatus.completed && wf.completedAt == 3);
  assert(failsWith(IaErrorKind.ruleViolation, () { wf.terminate("x", 4); }));

  WorkflowTask t;
  t.id = WorkflowTaskId("t");
  t.workflowId = wf.id;
  t.name = "Approve";
  t.taskType = TaskType.approval;
  assert(failsWith(IaErrorKind.ruleViolation, () { t.complete("ok", "u", 1); }));
  assert(failsWith(IaErrorKind.ruleViolation, () { t.skip("no", "u", 1); }));
  t.start("u", 10);
  t.fail("rejected", "u", 20_010);
  assert(t.status == TaskStatus.failed && t.durationMs == 2);
  t.retry();
  t.start("u", 30);
  t.complete("approved", "u", 40);
  assert(t.status == TaskStatus.completed && t.attempts == 2 && t.result == "approved");
}
