/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors: the policy, auditing, the execution
/// log, workflow progress and the generic resource interactor (create /
/// PATCH / get / list / delete with validation, immutable attributes and
/// events).
module uim.platform.integration_automation.application.services.support;

import std.traits : FieldNameTuple;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct IaPolicy {
  int maxOpenWorkflows = 15; /// open workflows per tenant (SAP CIAS limit)
  bool runAutomationImmediately; /// execute ready automated tasks inline (no background worker)
  int maxFailedLogins = 5; /// failed logins before a temporary lock
  long lockSeconds = 900; /// duration of the temporary lock
  size_t minPasswordLength = 10;
}

/// Actor of the automation gateway.
enum string automationActor = "automation";

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw IaException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw IaException.invalid("Tenant is required");
  entity.id = TId(id);
  entity.tenantId = tenantId;
  entity.createdAt = now;
  entity.updatedAt = now;
  entity.createdBy = actor;
  entity.updatedBy = actor;
}

/// Refresh the audit fields of a changed entity.
void stampUpdated(E)(ref E entity, UserId actor, long now) {
  entity.updatedAt = now;
  entity.updatedBy = actor;
}

/// Base class of all interactors: repositories, clock, events, unit of work and policy.
abstract class IaInteractor {
  protected IaRepositories repos;
  protected IClock clock;
  protected IIaEventPublisher events;
  protected IIaUnitOfWork unitOfWork;
  protected IaPolicy policy;
  private static long lastLogTime; /// keeps log entries of one operation in order

  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateIaUnitOfWork;
    this.policy = policy;
  }

  protected long now() {
    return clock.now();
  }

  protected void emit(string type, TenantId t, string subject, Json data = Json.emptyObject) {
    events.publish(type, t, subject, data);
  }

  protected void batch(scope void delegate() @safe work) {
    unitOfWork.batch(work);
  }

  /// Write an execution log entry and publish the matching event.
  protected ExecutionLog record(TenantId t, WorkflowId workflow, WorkflowTaskId task, string action,
    ExecutionOutcome outcome, string message, string by, long durationMs = 0, string details = "") {
    auto at = now;
    if (at <= lastLogTime)
      at = lastLogTime + 1;
    lastLogTime = at;
    ExecutionLog l;
    stampCreated!(ExecutionLog, ExecutionLogId)(l, t, UserId(by), newResourceId(), at);
    l.workflowId = workflow;
    l.taskId = task;
    l.action = action;
    l.outcome = outcome;
    l.message = message.length > 2000 ? message[0 .. 2000] : message;
    l.details = details.length > 8000 ? details[0 .. 8000] : details;
    l.executedBy = by;
    l.durationMs = durationMs;
    repos.executionLogs.save(l);
    auto data = Json.emptyObject;
    data["workflowId"] = workflow.value;
    data["outcome"] = cast(string) outcome;
    emit(action, t, task.isNull ? workflow.value : task.value, data);
    return l;
  }

  // ── workflows ───────────────────────────────────────────────────────────

  protected Workflow workflowOf(TenantId t, WorkflowId id) {
    if (id.isNull)
      throw IaException.invalid("Workflow is required");
    return required(repos.workflows.findById(t, id), "Workflow '" ~ id.value ~ "'");
  }

  protected WorkflowTask[] tasksOf(TenantId t, WorkflowId id) {
    return inSequence(repos.workflowTasks.findByReference(t, "workflowId", id.value));
  }

  /// Recompute the progress of a workflow, log completion / failure changes.
  protected Workflow refreshWorkflow(TenantId t, Workflow wf, UserId actor) {
    auto before = wf.status;
    wf.apply(progressOf(tasksOf(t, wf.id)), now);
    stampUpdated(wf, actor, now);
    repos.workflows.save(wf);
    if (wf.status != before) {
      if (wf.status == WorkflowStatus.completed)
        record(t, wf.id, WorkflowTaskId.init, "workflow.completed", ExecutionOutcome.success,
          format("Workflow '%s' completed (%d tasks)", wf.name, wf.totalTasks), actor.value,
          millisBetween(wf.startedAt, wf.completedAt));
      else if (wf.status == WorkflowStatus.failed)
        record(t, wf.id, WorkflowTaskId.init, "workflow.failed", ExecutionOutcome.failure,
          format("Workflow '%s' stopped at a failed task — retry or skip it", wf.name), actor.value);
      else if (before == WorkflowStatus.failed && wf.status == WorkflowStatus.inProgress)
        record(t, wf.id, WorkflowTaskId.init, "workflow.recovered", ExecutionOutcome.info,
          format("Workflow '%s' continues", wf.name), actor.value);
    }
    return wf;
  }

  // ── references ──────────────────────────────────────────────────────────

  /// An optional reference: "" stays empty, anything else must exist.
  protected string optionalReference(TId, R)(R repo, TenantId t, string id, string what) {
    auto v = id.strip;
    if (v.length == 0)
      return "";
    if (!repo.existsById(t, TId(v)))
      throw IaException.notFound(what ~ " '" ~ v ~ "'");
    return v;
  }

  /// Refuse an operation while references exist ("… is used by 3 destinations").
  protected void requireUnused(string what, long count, string users) {
    if (count > 0)
      throw IaException.ruleViolation(format("%s is still used by %d %s", what, count, users));
  }
}

/// Generic interactor of a maintained resource. Subclasses map the input
/// onto the entity (fromInput/toInput) and add reference checks.
abstract class ResourceInteractor(TEntity, TId, TInput) : IaInteractor, IManageResource!(TEntity, TId, TInput) {
  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected abstract IIaRepository!(TEntity, TId) store();
  /// "System" (messages)
  protected abstract string what();
  /// "system" (events)
  protected abstract string eventPrefix();
  protected abstract TInput toInput(const TEntity e);
  /// Map (parse, check references); creating = false for updates.
  protected abstract void fromInput(TenantId t, ref TEntity e, TInput input, bool creating);

  /// Input members that cannot change after creation.
  protected string[] immutableAttributes() {
    return null;
  }

  /// Reference checks and cascades (inside the batch of the removal).
  protected void beforeRemove(TenantId t, const TEntity e, UserId actor) {
  }

  TEntity create(CreateCommand!TInput c) {
    auto id = idOrNew(c.id, what ~ " ID");
    if (store.existsById(c.tenantId, TId(id)))
      throw IaException.conflict(what ~ " '" ~ id ~ "' already exists");
    TInput input;
    c.input.applyTo(input);
    TEntity e;
    stampCreated!(TEntity, TId)(e, c.tenantId, c.actor, id, now);
    fromInput(c.tenantId, e, input, true);
    e.validate();
    store.save(e);
    emit(eventPrefix ~ ".created", c.tenantId, id);
    return e;
  }

  TEntity update(UpdateCommand!TInput c) @trusted {
    auto e = get(c.tenantId, TId(c.id));
    auto before = toInput(e);
    auto after = before;
    c.changes.applyTo(after);
    auto fixed = immutableAttributes;
    static foreach (name; FieldNameTuple!TInput)
      if (fixed.canFind(name) && __traits(getMember, after, name) != __traits(getMember, before, name))
        throw IaException.invalid("'" ~ name ~ "' of " ~ what.toLower ~ " '" ~ c.id ~ "' cannot be changed");
    fromInput(c.tenantId, e, after, false);
    e.validate();
    stampUpdated(e, c.actor, now);
    store.save(e);
    emit(eventPrefix ~ ".updated", c.tenantId, c.id, Json(["fields": Json(c.changes.fields.join(","))]));
    return e;
  }

  TEntity get(TenantId t, TId id) {
    return required(store.findById(t, id), what ~ " '" ~ id.value ~ "'");
  }

  TEntity[] list(TenantId t) {
    return store.findAll(t);
  }

  void remove(TenantId t, TId id, UserId actor) {
    auto e = get(t, id);
    batch(() {
      beforeRemove(t, e, actor);
      store.removeById(t, id);
    });
    emit(eventPrefix ~ ".deleted", t, id.value, Json(["by": Json(actor.value)]));
  }
}
