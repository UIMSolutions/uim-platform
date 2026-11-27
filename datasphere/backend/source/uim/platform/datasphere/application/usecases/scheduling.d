/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Scheduling and monitoring: tasks, task chains and the run log.
///
///   * a task runs a remote table, data flow or view of its own space
///   * a task cannot be deleted while a task chain contains it
///   * the steps of a chain are tasks of the chain's space
///   * the scheduler (worker or "RunDueSchedules") runs what is due; a due
///     schedule of a locked space is skipped and planned again
module uim.platform.datasphere.application.usecases.scheduling;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// The std time of an ISO text, or the fallback for "".
private long startTimeOf(string text, long fallback) {
  auto t = parseIsoTime(text, "Start");
  return t > 0 ? t : fallback;
}

class ManageTasksUseCase : ResourceInteractor!(DataTask, TaskId, TaskInput), IManageTasks {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(DataTask, TaskId) store() {
    return repos.tasks;
  }

  protected override string what() {
    return "Task";
  }

  protected override string eventPrefix() {
    return "task";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId", "taskType"];
  }

  protected override TaskInput toInput(const DataTask e) {
    TaskInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.description = e.description;
    i.taskType = cast(string) e.taskType;
    i.targetObjectId = e.targetObjectId;
    i.frequency = cast(string) e.frequency;
    i.intervalMinutes = e.intervalMinutes;
    i.startAt = isoTimeText(e.startAt);
    i.maxRetries = e.maxRetries;
    return i;
  }

  protected override void fromInput(TenantId t, ref DataTask e, TaskInput i, bool creating) {
    if (creating)
      activeSpace(t, i.spaceId, "Creating a task");
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.taskType = parseDomainEnum!TaskType(i.taskType, "task type");
    e.targetObjectId = i.targetObjectId.strip;
    e.frequency = parseDomainEnum!ScheduleFrequency(i.frequency, "frequency");
    e.intervalMinutes = e.frequency == ScheduleFrequency.interval ? i.intervalMinutes : 0;
    e.startAt = startTimeOf(i.startAt, creating ? e.createdAt : e.startAt);
    e.maxRetries = i.maxRetries;
    requireTarget(t, e);
  }

  protected override void beforeSave(TenantId t, ref DataTask e, bool creating) {
    e.reschedule(now);
  }

  /// The target exists in the task's space.
  protected void requireTarget(TenantId t, const DataTask e) {
    SpaceId owner;
    final switch (e.taskType) {
    case TaskType.replication:
      owner = required(repos.remoteTables.findById(t, RemoteTableId(e.targetObjectId)),
        "Remote table '" ~ e.targetObjectId ~ "'").spaceId;
      break;
    case TaskType.dataFlow:
      owner = required(repos.dataFlows.findById(t, DataFlowId(e.targetObjectId)), "Data flow '" ~ e.targetObjectId ~ "'").spaceId;
      break;
    case TaskType.viewPersistence:
      owner = required(repos.views.findById(t, DataViewId(e.targetObjectId)), "View '" ~ e.targetObjectId ~ "'").spaceId;
      break;
    }
    if (owner != e.spaceId)
      throw DspException.ruleViolation("'" ~ e.targetObjectId ~ "' belongs to space '" ~ owner.value ~ "'");
  }

  protected override void beforeRemove(TenantId t, const DataTask e, UserId actor) {
    auto chains = repos.taskChains.findByReference(t, "spaceId", e.spaceId.value).count!(c => c.taskIds.canFind(e.id.value));
    requireUnused("Task '" ~ e.name ~ "'", chains, "task chains");
  }

  TaskRun runTask(TenantId t, TaskId id, UserId actor) {
    auto task = get(t, id);
    TaskRun run;
    batch(() { run = runner.runTask(t, task, RunTrigger.manual, actor); });
    return run;
  }

  DataTask pause(TenantId t, TaskId id, UserId actor) {
    return setStatus(t, id, ScheduleStatus.paused, actor);
  }

  DataTask resume(TenantId t, TaskId id, UserId actor) {
    return setStatus(t, id, ScheduleStatus.active, actor);
  }

  protected DataTask setStatus(TenantId t, TaskId id, ScheduleStatus status, UserId actor) {
    auto task = get(t, id);
    task.status = status;
    task.reschedule(now);
    stampUpdated(task, actor, now);
    repos.tasks.save(task);
    emit(status == ScheduleStatus.paused ? "task.paused" : "task.resumed", t, id.value);
    return task;
  }
}

class ManageTaskChainsUseCase : ResourceInteractor!(TaskChain, TaskChainId, TaskChainInput), IManageTaskChains {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(TaskChain, TaskChainId) store() {
    return repos.taskChains;
  }

  protected override string what() {
    return "Task chain";
  }

  protected override string eventPrefix() {
    return "taskChain";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId"];
  }

  protected override TaskChainInput toInput(const TaskChain e) {
    TaskChainInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.description = e.description;
    i.taskIds = e.taskIds.dup;
    i.failurePolicy = cast(string) e.failurePolicy;
    i.frequency = cast(string) e.frequency;
    i.intervalMinutes = e.intervalMinutes;
    i.startAt = isoTimeText(e.startAt);
    return i;
  }

  protected override void fromInput(TenantId t, ref TaskChain e, TaskChainInput i, bool creating) {
    if (creating)
      activeSpace(t, i.spaceId, "Creating a task chain");
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.taskIds = i.taskIds.map!(s => s.strip).filter!(s => s.length > 0).array;
    e.failurePolicy = parseDomainEnum!FailurePolicy(i.failurePolicy, "failure policy");
    e.frequency = parseDomainEnum!ScheduleFrequency(i.frequency, "frequency");
    e.intervalMinutes = e.frequency == ScheduleFrequency.interval ? i.intervalMinutes : 0;
    e.startAt = startTimeOf(i.startAt, creating ? e.createdAt : e.startAt);
    foreach (id; e.taskIds) {
      auto task = required(repos.tasks.findById(t, TaskId(id)), "Task '" ~ id ~ "'");
      if (task.spaceId != e.spaceId)
        throw DspException.ruleViolation("Task '" ~ id ~ "' belongs to space '" ~ task.spaceId.value ~ "'");
    }
  }

  protected override void beforeSave(TenantId t, ref TaskChain e, bool creating) {
    e.reschedule(now);
  }

  TaskRun runChain(TenantId t, TaskChainId id, UserId actor) {
    return runner.runChain(t, get(t, id), RunTrigger.manual, actor);
  }

  TaskChain pause(TenantId t, TaskChainId id, UserId actor) {
    return setStatus(t, id, ScheduleStatus.paused, actor);
  }

  TaskChain resume(TenantId t, TaskChainId id, UserId actor) {
    return setStatus(t, id, ScheduleStatus.active, actor);
  }

  protected TaskChain setStatus(TenantId t, TaskChainId id, ScheduleStatus status, UserId actor) {
    auto chain = get(t, id);
    chain.status = status;
    chain.reschedule(now);
    stampUpdated(chain, actor, now);
    repos.taskChains.save(chain);
    emit(status == ScheduleStatus.paused ? "taskChain.paused" : "taskChain.resumed", t, id.value);
    return chain;
  }
}

class MonitorRunsUseCase : DspInteractor, IMonitorRuns {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  TaskRun[] listRuns(TenantId t) {
    return repos.runs.findAll(t);
  }

  TaskRun getRun(TenantId t, TaskRunId id) {
    return required(repos.runs.findById(t, id), "Run '" ~ id.value ~ "'");
  }

  SchedulerSummary runDue(TenantId t, UserId actor) {
    SchedulerSummary s;
    auto at = now;
    bool[string] locked;
    foreach (space; repos.spaces.findAll(t))
      if (!space.isActive)
        locked[space.id.value] = true;
    batch(() {
      size_t budget = policy.maxSchedulerBatch;
      // chains first: their steps must not also fire as single tasks in the same run
      bool[string] inChain;
      foreach (chain; repos.taskChains.findAll(t)) {
        if (!chain.isDue(at) || budget == 0)
          continue;
        s.due++;
        if (chain.spaceId.value in locked) {
          s.skipped++;
          chain.reschedule(at);
          repos.taskChains.save(chain);
          continue;
        }
        budget--;
        foreach (id; chain.taskIds)
          inChain[id] = true;
        s.add(runner.runChain(t, chain, RunTrigger.schedule, actor), chain.name);
      }
      foreach (task; repos.tasks.findAll(t)) {
        if (!task.isDue(at) || budget == 0)
          continue;
        s.due++;
        if (task.spaceId.value in locked || task.id.value in inChain) {
          s.skipped++;
          task.reschedule(at);
          repos.tasks.save(task);
          continue;
        }
        budget--;
        s.add(runner.runTask(t, task, RunTrigger.schedule, actor), task.name);
      }
    });
    if (s.due > 0)
      emit("scheduler.run", t, "", Json(["summary": Json(s.summary)]));
    return s;
  }

  PurgeResult purgeRuns(TenantId t, UserId actor) {
    PurgeResult r;
    batch(() { r.runs = repos.runs.removeFinishedBefore(t, plusDays(now, -policy.runRetentionDays)); });
    if (r.runs > 0)
      emit("runs.purged", t, "", Json(["runs": Json(r.runs), "by": Json(actor.value)]));
    return r;
  }
}
