/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors: the policy, auditing, references and
/// the generic resource interactor (create / PATCH / get / list / delete
/// with validation, immutable attributes and events).
module uim.platform.application_autoscaler.application.services.support;

import std.traits : FieldNameTuple;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct AasPolicy {
  long metricStaleSeconds = 600; /// newer samples are needed for a rule to fire
  long metricRetentionHours = 48; /// older samples are purged
  long eventRetentionDays = 30; /// older scaling events are purged
  int maxSimulationSamples = 240; /// samples a load simulation may create
  bool recordIgnored; /// also keep evaluations that changed nothing in the history
  int maxFailedLogins = 5; /// failed logins before a temporary lock
  long lockSeconds = 900; /// duration of the temporary lock
  size_t minPasswordLength = 10;
}

/// Actor of the background worker.
enum string workerActor = "worker";

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw AasException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw AasException.invalid("Tenant is required");
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
abstract class AasInteractor {
  protected AasRepositories repos;
  protected IClock clock;
  protected IAasEventPublisher events;
  protected IAasUnitOfWork unitOfWork;
  protected AasPolicy policy;
  private long lastTime; /// strictly increasing creation times keep lists in order

  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateAasUnitOfWork;
    this.policy = policy;
  }

  protected long now() {
    return clock.now();
  }

  /// A creation time after the previous one of this interactor (stable order).
  protected long nextTime() {
    auto at = now;
    if (at <= lastTime)
      at = lastTime + 1;
    lastTime = at;
    return at;
  }

  protected void emit(string type, TenantId t, string subject, Json data = Json.emptyObject) {
    events.publish(type, t, subject, data);
  }

  protected void batch(scope void delegate() @safe work) {
    unitOfWork.batch(work);
  }

  /// An optional reference: "" stays empty, anything else must exist.
  protected string optionalReference(TId, R)(R repo, TenantId t, string id, string what) {
    auto v = id.strip;
    if (v.length == 0)
      return "";
    if (!repo.existsById(t, TId(v)))
      throw AasException.notFound(what ~ " '" ~ v ~ "'");
    return v;
  }

  /// Refuse an operation while references exist ("… is used by 3 bindings").
  protected void requireUnused(string what, long count, string users) {
    if (count > 0)
      throw AasException.ruleViolation(format("%s is still used by %d %s", what, count, users));
  }

  protected AppBinding bindingOf(TenantId t, AppBindingId id) {
    if (id.isNull)
      throw AasException.invalid("Binding is required");
    return required(repos.bindings.findById(t, id), "Binding '" ~ id.value ~ "'");
  }

  protected ScalingPolicy policyOf(TenantId t, ScalingPolicyId id) {
    if (id.isNull)
      throw AasException.invalid("Policy is required");
    return required(repos.policies.findById(t, id), "Policy '" ~ id.value ~ "'");
  }
}

/// Generic interactor of a maintained resource. Subclasses map the input
/// onto the entity (fromInput/toInput) and add reference checks.
abstract class ResourceInteractor(TEntity, TId, TInput) : AasInteractor, IManageResource!(TEntity, TId, TInput) {
  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected abstract IAasRepository!(TEntity, TId) store();
  /// "Policy" (messages)
  protected abstract string what();
  /// "policy" (events)
  protected abstract string eventPrefix();
  protected abstract TInput toInput(const TEntity e);
  /// Map (parse, check references); creating = false for updates.
  protected abstract void fromInput(TenantId t, ref TEntity e, TInput input, bool creating);

  /// Input members that cannot change after creation.
  protected string[] immutableAttributes() {
    return null;
  }

  /// Checks after mapping and validation, before saving (cross-entity rules).
  protected void beforeSave(TenantId t, const TEntity e, bool creating) {
  }

  /// Reference checks and cascades (inside the batch of the removal).
  protected void beforeRemove(TenantId t, const TEntity e, UserId actor) {
  }

  TEntity create(CreateCommand!TInput c) {
    auto id = idOrNew(c.id, what ~ " ID");
    if (store.existsById(c.tenantId, TId(id)))
      throw AasException.conflict(what ~ " '" ~ id ~ "' already exists");
    TInput input;
    c.input.applyTo(input);
    TEntity e;
    stampCreated!(TEntity, TId)(e, c.tenantId, c.actor, id, nextTime);
    fromInput(c.tenantId, e, input, true);
    e.validate();
    beforeSave(c.tenantId, e, true);
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
        throw AasException.invalid("'" ~ name ~ "' of " ~ what.toLower ~ " '" ~ c.id ~ "' cannot be changed");
    fromInput(c.tenantId, e, after, false);
    e.validate();
    beforeSave(c.tenantId, e, false);
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
