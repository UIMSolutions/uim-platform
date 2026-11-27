/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Executes the data work and logs every run (data integration monitor):
///
///   replication       snapshot of a remote table; the connection is
///                     validated first if it was never tested
///   dataFlow          a deployed data flow over its sources into its target
///   viewPersistence   materialises a deployed view
///   task              one of the above with retries (each attempt is a run)
///   taskChain         the tasks of a chain in order; stop or continue on failure
///
/// A run fails — it never throws — when the space is locked, an object is
/// missing or not deployed, the processing engine reports an error or the
/// result would exceed the disk quota of the space. Successful runs update
/// the object (rows, size, timestamps) and the used disk of the space.
module uim.platform.datasphere.application.services.runner;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// Bytes per row assumed for data flow targets (no column definitions).
enum long flowRowBytes = 64;

/// How a run was started.
struct RunContext {
  RunTrigger trigger = RunTrigger.manual;
  UserId actor;
  string taskId;
  string chainRunId;
  int attempt = 1;
}

/// What the work of a run produced.
private struct WorkOutcome {
  bool ok;
  string objectName;
  long rows;
  long bytes;
  long durationMs;
  string message;
}

class RunService : DspInteractor {
  protected IProcessingEngine engine;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy,
    IProcessingEngine engine) {
    super(repos, clock, audit, unitOfWork, policy);
    this.engine = engine;
  }

  string engineMode() {
    return engine.mode;
  }

  // ── connections ───────────────────────────────────────────────────────────

  /// Check a connection with the engine and store the result.
  Connection checkConnection(Connection c, UserId actor) {
    auto r = engine.checkConnection(c);
    c.status = r.ok ? ConnectionStatus.valid : ConnectionStatus.invalid;
    c.statusMessage = r.message;
    c.lastValidatedAt = now;
    stampUpdated(c, actor, now);
    repos.connections.save(c);
    emit(r.ok ? "connection.validated" : "connection.failed", c.tenantId, c.id.value, Json(["message": Json(r.message)]));
    return c;
  }

  // ── single runs ───────────────────────────────────────────────────────────

  TaskRun replicate(TenantId t, SpaceId spaceId, RemoteTableId id, RunContext rc) {
    return execute(t, spaceId, RunObjectType.replication, id.value, rc, () {
      auto table = required(repos.remoteTables.findById(t, id), "Remote table '" ~ id.value ~ "'");
      WorkOutcome w;
      w.objectName = table.name;
      auto conn = required(repos.connections.findById(t, table.connectionId), "Connection '" ~ table.connectionId.value ~ "'");
      if (conn.status == ConnectionStatus.untested)
        conn = checkConnection(conn, rc.actor);
      if (!conn.isValid)
        return failed(w, "connection '" ~ conn.name ~ "' is invalid: " ~ conn.statusMessage);
      if (table.replicationMode == ReplicationMode.realtime && !conn.connectionType.supportsRealtime)
        return failed(w, "connection type '" ~ cast(string) conn.connectionType ~ "' does not support real-time replication");
      auto r = engine.replicate(conn, table);
      w.durationMs = r.durationMs;
      if (!r.ok) {
        table.lastMessage = r.message;
        if (!table.holdsData)
          table.replicationStatus = ReplicationStatus.failed;
        repos.remoteTables.save(table);
        return failed(w, r.message);
      }
      auto bytes = r.rows * estimateRowBytes(table.columns);
      if (auto quota = quotaProblem(t, table.spaceId, table.holdsData ? table.sizeBytes : 0, bytes))
        return failed(w, quota);
      table.rowCount = r.rows;
      table.sizeBytes = bytes;
      table.replicationStatus = table.replicationMode == ReplicationMode.realtime ? ReplicationStatus.active
        : ReplicationStatus.replicated;
      if (table.replicationMode == ReplicationMode.remote)
        table.replicationMode = ReplicationMode.snapshot;
      table.lastReplicatedAt = now;
      table.lastMessage = r.message;
      stampUpdated(table, rc.actor, now);
      repos.remoteTables.save(table);
      return succeeded(w, r.rows, bytes, r.message);
    });
  }

  TaskRun runDataFlow(TenantId t, SpaceId spaceId, DataFlowId id, RunContext rc) {
    return execute(t, spaceId, RunObjectType.dataFlow, id.value, rc, () {
      auto flow = required(repos.dataFlows.findById(t, id), "Data flow '" ~ id.value ~ "'");
      WorkOutcome w;
      w.objectName = flow.name;
      if (!flow.isDeployed)
        return failed(w, "data flow '" ~ flow.name ~ "' is not deployed");
      flow.requireDeployable();
      long input;
      foreach (s; flow.sourceObjects)
        input += objectRows(t, flow.spaceId, s, 0);
      auto r = engine.runDataFlow(flow, input);
      w.durationMs = r.durationMs;
      if (!r.ok) {
        recordFlow(flow, RunStatus.failed, r, rc.actor);
        return failed(w, r.message);
      }
      final switch (flow.loadMode) {
      case LoadMode.append:
        flow.targetRows += r.rows;
        break;
      case LoadMode.truncate:
        flow.targetRows = r.rows;
        break;
      case LoadMode.upsert:
        flow.targetRows = max(flow.targetRows, r.rows);
        break;
      }
      auto bytes = flow.targetRows * flowRowBytes;
      if (auto quota = quotaProblem(t, flow.spaceId, flow.targetBytes, bytes)) {
        recordFlow(flow, RunStatus.failed, ProcessingResult(false, 0, r.durationMs, quota), rc.actor);
        return failed(w, quota);
      }
      flow.targetBytes = bytes;
      recordFlow(flow, RunStatus.completed, r, rc.actor);
      return succeeded(w, r.rows, bytes, r.message);
    });
  }

  TaskRun persistView(TenantId t, SpaceId spaceId, DataViewId id, RunContext rc) {
    return execute(t, spaceId, RunObjectType.viewPersistence, id.value, rc, () {
      auto view = required(repos.views.findById(t, id), "View '" ~ id.value ~ "'");
      WorkOutcome w;
      w.objectName = view.name;
      if (!view.isDeployed)
        return failed(w, "view '" ~ view.name ~ "' is not deployed");
      long input;
      foreach (s; view.sourceObjects)
        input += objectRows(t, view.spaceId, s, 0);
      auto r = engine.persistView(view, input);
      w.durationMs = r.durationMs;
      view.lastRunStatus = r.ok ? RunStatus.completed : RunStatus.failed;
      view.lastRunMessage = r.message;
      if (!r.ok) {
        repos.views.save(view);
        return failed(w, r.message);
      }
      auto bytes = r.rows * estimateRowBytes(view.columns);
      if (auto quota = quotaProblem(t, view.spaceId, view.persisted ? view.persistedBytes : 0, bytes)) {
        view.lastRunStatus = RunStatus.failed;
        view.lastRunMessage = quota;
        repos.views.save(view);
        return failed(w, quota);
      }
      view.persisted = true;
      view.rowCount = r.rows;
      view.persistedBytes = bytes;
      view.persistedAt = now;
      stampUpdated(view, rc.actor, now);
      repos.views.save(view);
      return succeeded(w, r.rows, bytes, r.message);
    });
  }

  // ── tasks and chains ──────────────────────────────────────────────────────

  /// Run a task with its retries; updates and reschedules the task.
  TaskRun runTask(TenantId t, DataTask task, RunTrigger trigger, UserId actor, string chainRunId = "") {
    TaskRun last;
    foreach (attempt; 1 .. task.maxRetries + 2) {
      RunContext rc;
      rc.trigger = trigger;
      rc.actor = actor;
      rc.taskId = task.id.value;
      rc.chainRunId = chainRunId;
      rc.attempt = attempt;
      last = dispatch(t, task, rc);
      if (last.succeeded || last.message.canFind("is locked"))
        break;
    }
    // re-read: the run may have changed the task's space objects, not the task itself
    auto current = repos.tasks.findById(t, task.id);
    if (!current.isNull)
      task = current;
    task.recordRun(last.status, last.startedAt, last.durationMs, last.message);
    task.reschedule(now);
    repos.tasks.save(task);
    return last;
  }

  /// Run the steps of a chain in order.
  TaskRun runChain(TenantId t, TaskChain chain, RunTrigger trigger, UserId actor) {
    auto space = repos.spaces.findById(t, chain.spaceId);
    TaskRun run;
    stampCreated!(TaskRun, TaskRunId)(run, t, actor, newResourceId(), nextTime);
    run.spaceId = chain.spaceId;
    run.objectType = RunObjectType.taskChain;
    run.objectId = chain.id.value;
    run.objectName = chain.name;
    run.trigger = trigger;
    run.startedAt = run.createdAt;
    if (space.isNull || !space.isActive) {
      run.finish(RunStatus.failed, run.startedAt, space.isNull ? "space '" ~ chain.spaceId.value ~ "' not found"
          : "space '" ~ space.id.value ~ "' is locked");
      repos.runs.save(run);
    } else {
      repos.runs.save(run);
      long failures, completed, cancelled, duration, rows;
      string firstFailure;
      batch(() {
        foreach (i, taskId; chain.taskIds) {
          auto task = repos.tasks.findById(t, TaskId(taskId));
          auto stop = failures > 0 && chain.failurePolicy == FailurePolicy.stop;
          if (stop || task.isNull) {
            TaskRun step;
            stampCreated!(TaskRun, TaskRunId)(step, t, actor, newResourceId(), nextTime);
            step.spaceId = chain.spaceId;
            step.objectType = task.isNull ? RunObjectType.replication : runObjectOf(task.taskType);
            step.objectId = task.isNull ? taskId : task.targetObjectId;
            step.objectName = task.isNull ? taskId : task.name;
            step.taskId = taskId;
            step.chainRunId = run.id.value;
            step.trigger = RunTrigger.chain;
            step.startedAt = step.createdAt;
            if (stop) {
              step.finish(RunStatus.cancelled, step.startedAt, "cancelled: an earlier step failed");
              cancelled++;
            } else {
              step.finish(RunStatus.failed, step.startedAt, "task '" ~ taskId ~ "' not found");
              failures++;
              if (firstFailure.length == 0)
                firstFailure = step.message;
            }
            repos.runs.save(step);
            continue;
          }
          auto r = runTask(t, task, RunTrigger.chain, actor, run.id.value);
          duration += r.durationMs;
          rows += r.rowsProcessed;
          if (r.succeeded)
            completed++;
          else {
            failures++;
            if (firstFailure.length == 0)
              firstFailure = task.name ~ ": " ~ r.message;
          }
        }
      });
      auto steps = chain.taskIds.length;
      run.rowsProcessed = rows;
      auto text = failures == 0 ? format("%d of %d steps completed", completed, steps)
        : format("%d of %d steps failed, %d cancelled — %s", failures, steps, cancelled, firstFailure);
      if (steps == 0)
        text = "the chain has no steps";
      run.finish(failures == 0 ? RunStatus.completed : RunStatus.failed, run.startedAt + duration * 10_000, text);
      repos.runs.save(run);
    }
    auto current = repos.taskChains.findById(t, chain.id);
    if (!current.isNull)
      chain = current;
    chain.lastRunStatus = run.status;
    chain.lastRunAt = run.startedAt;
    chain.lastRunDurationMs = run.durationMs;
    chain.lastRunMessage = run.message;
    chain.reschedule(now);
    repos.taskChains.save(chain);
    emit(run.succeeded ? "chain.completed" : "chain.failed", t, chain.id.value, Json(["run": Json(run.id.value)]));
    return run;
  }

  // ── space usage ───────────────────────────────────────────────────────────

  /// Current disk usage of the space's objects.
  long usageOf(TenantId t, SpaceId s) {
    return diskUsage(repos.remoteTables.findByReference(t, "spaceId", s.value),
      repos.views.findByReference(t, "spaceId", s.value), repos.dataFlows.findByReference(t, "spaceId", s.value));
  }

  /// Store the current usage on the space.
  Space refreshUsage(TenantId t, SpaceId s) {
    auto space = repos.spaces.findById(t, s);
    if (space.isNull)
      return space;
    auto used = usageOf(t, s);
    if (space.usedDiskBytes != used) {
      space.usedDiskBytes = used;
      repos.spaces.save(space);
    }
    return space;
  }

  /// Rows an object of the space provides (replicas and persisted views
  /// their row count; federated tables an estimate; views their sources).
  long objectRows(TenantId t, SpaceId s, string name, int depth) {
    import std.uni : icmp;

    if (depth > 8)
      return 0;
    foreach (x; repos.remoteTables.findByReference(t, "spaceId", s.value))
      if (icmp(x.name, name) == 0)
        return x.holdsData ? x.rowCount : policy.federatedRowEstimate;
    foreach (x; repos.views.findByReference(t, "spaceId", s.value))
      if (icmp(x.name, name) == 0) {
        if (x.persisted)
          return x.rowCount;
        long rows;
        foreach (src; x.sourceObjects)
          rows += objectRows(t, s, src, depth + 1);
        return rows;
      }
    foreach (x; repos.dataFlows.findByReference(t, "spaceId", s.value))
      if (icmp(x.targetTable, name) == 0)
        return x.targetRows;
    return 0;
  }

  // ── internals ─────────────────────────────────────────────────────────────

  protected TaskRun dispatch(TenantId t, const DataTask task, RunContext rc) {
    final switch (task.taskType) {
    case TaskType.replication:
      return replicate(t, task.spaceId, RemoteTableId(task.targetObjectId), rc);
    case TaskType.dataFlow:
      return runDataFlow(t, task.spaceId, DataFlowId(task.targetObjectId), rc);
    case TaskType.viewPersistence:
      return persistView(t, task.spaceId, DataViewId(task.targetObjectId), rc);
    }
  }

  /// The skeleton of every single run: space check, work, log entry, usage.
  protected TaskRun execute(TenantId t, SpaceId spaceId, RunObjectType type, string objectId, RunContext rc,
    scope WorkOutcome delegate() @safe work) {
    TaskRun run;
    stampCreated!(TaskRun, TaskRunId)(run, t, rc.actor, newResourceId(), nextTime);
    run.spaceId = spaceId;
    run.objectType = type;
    run.objectId = objectId;
    run.objectName = objectId;
    run.taskId = rc.taskId;
    run.chainRunId = rc.chainRunId;
    run.trigger = rc.trigger;
    run.attempts = rc.attempt;
    run.startedAt = run.createdAt;
    WorkOutcome w;
    auto space = repos.spaces.findById(t, spaceId);
    if (space.isNull)
      w.message = "space '" ~ spaceId.value ~ "' not found";
    else if (!space.isActive)
      w.message = "space '" ~ spaceId.value ~ "' is locked" ~ (space.lockedReason.length ? " (" ~ space.lockedReason ~ ")" : "");
    else {
      try
        w = work();
      catch (DatasphereException e) {
        w.ok = false;
        w.message = e.msg;
      }
    }
    if (w.objectName.length)
      run.objectName = w.objectName;
    run.rowsProcessed = w.rows;
    run.sizeBytes = w.bytes;
    run.finish(w.ok ? RunStatus.completed : RunStatus.failed, run.startedAt + w.durationMs * 10_000, w.message);
    run.validate();
    repos.runs.save(run);
    if (w.ok)
      refreshUsage(t, spaceId);
    emit(w.ok ? "run.completed" : "run.failed", t, run.id.value, Json([
        "type": Json(cast(string) type), "object": Json(objectId), "attempt": Json(rc.attempt), "message": Json(w.message)
      ]));
    return run;
  }

  /// A message if replacing oldBytes by newBytes would exceed the quota, else null.
  protected string quotaProblem(TenantId t, SpaceId s, long oldBytes, long newBytes) {
    if (!policy.enforceQuota)
      return null;
    auto space = repos.spaces.findById(t, s);
    if (space.isNull)
      return null;
    auto projected = usageOf(t, s) - oldBytes + newBytes;
    if (projected <= space.diskQuotaBytes)
      return null;
    return format("disk quota of space '%s' exceeded (%.2f of %.2f GiB)", s.value, cast(double) projected / bytesPerGiB,
      cast(double) space.diskQuotaBytes / bytesPerGiB);
  }

  protected void recordFlow(ref DataFlow flow, RunStatus result, ProcessingResult r, UserId actor) {
    flow.lastRunStatus = result;
    flow.lastRunAt = now;
    flow.lastRunDurationMs = r.durationMs;
    flow.lastRunMessage = r.message;
    stampUpdated(flow, actor, now);
    repos.dataFlows.save(flow);
  }

  private static WorkOutcome failed(WorkOutcome w, string message) {
    w.ok = false;
    w.message = message;
    return w;
  }

  private static WorkOutcome succeeded(WorkOutcome w, long rows, long bytes, string message) {
    w.ok = true;
    w.rows = rows;
    w.bytes = bytes;
    w.message = message;
    return w;
  }
}
