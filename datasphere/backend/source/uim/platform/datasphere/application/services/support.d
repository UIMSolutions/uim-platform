/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors: the policy, auditing, references and
/// the generic resource interactor (create / PATCH / get / list / delete
/// with validation, immutable attributes and audit entries).
module uim.platform.datasphere.application.services.support;

import std.traits : FieldNameTuple;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct DspPolicy {
  bool enforceQuota = true; /// runs that would exceed the disk quota of the space fail
  long runRetentionDays = 30; /// finished runs are purged afterwards
  size_t maxSchedulerBatch = 100; /// tasks and chains per scheduler run
  long federatedRowEstimate = 10_000; /// rows assumed for a source that is not replicated
  int maxFailedLogins = 5; /// failed logins before a temporary lock
  long lockSeconds = 900; /// duration of the temporary lock
  size_t minPasswordLength = 10;
}

/// API name of an input member ("continue_" → "continue": D keywords).
string apiName(string member) pure {
  return member.length > 1 && member[$ - 1] == '_' ? member[0 .. $ - 1] : member;
}

/// Actor of the scheduler worker.
enum string schedulerActor = "scheduler";

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw DspException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw DspException.invalid("Tenant is required");
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

/// Case insensitive lookup of a technical name in a list.
bool containsName(const string[] names, string name) {
  import std.uni : icmp;

  return names.any!(n => icmp(n, name) == 0);
}

/// Base class of all interactors: repositories, clock, audit trail, unit of work and policy.
abstract class DspInteractor {
  protected DspRepositories repos;
  protected IClock clock;
  protected IAuditTrail audit;
  protected IDspUnitOfWork unitOfWork;
  protected DspPolicy policy;
  private long lastTime; /// strictly increasing creation times keep lists in order

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.audit = audit !is null ? audit : new NullAuditTrail;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateDspUnitOfWork;
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
    audit.record(type, t, subject, data);
  }

  protected void batch(scope void delegate() @safe work) {
    unitOfWork.batch(work);
  }

  /// Refuse an operation while references exist ("… is still used by 3 views").
  protected void requireUnused(string what, long count, string users) {
    if (count > 0)
      throw DspException.ruleViolation(format("%s is still used by %d %s", what, count, users));
  }

  protected Space spaceOf(TenantId t, SpaceId id) {
    if (id.isNull)
      throw DspException.invalid("Space is required");
    return required(repos.spaces.findById(t, id), "Space '" ~ id.value ~ "'");
  }

  /// The space of a new or changed object; it must exist and be active.
  protected Space activeSpace(TenantId t, string spaceId, string operation) {
    auto s = spaceOf(t, SpaceId(spaceId.strip));
    s.requireActive(operation);
    return s;
  }

  /// Technical names of the objects of a space that can be read (remote
  /// tables, views, data flow targets).
  protected string[] readableObjects(TenantId t, SpaceId s) {
    string[] names;
    foreach (x; repos.remoteTables.findByReference(t, "spaceId", s.value))
      names ~= x.name;
    foreach (x; repos.views.findByReference(t, "spaceId", s.value))
      names ~= x.name;
    foreach (x; repos.dataFlows.findByReference(t, "spaceId", s.value))
      if (x.targetTable.length)
        names ~= x.targetTable;
    return names;
  }

  /// Every name must be a readable object of the space.
  protected void requireObjects(TenantId t, SpaceId s, const string[] names, string what) {
    auto known = readableObjects(t, s);
    foreach (n; names)
      if (!known.containsName(n))
        throw DspException.ruleViolation(what ~ " '" ~ n ~ "' is not an object of space '" ~ s.value ~ "'");
  }

  /// A technical name must be unique among the readable objects of a space.
  protected void requireUniqueName(TenantId t, SpaceId s, string name, string ownName = "") {
    import std.uni : icmp;

    if (ownName.length && icmp(ownName, name) == 0)
      return;
    if (readableObjects(t, s).containsName(name))
      throw DspException.conflict("Space '" ~ s.value ~ "' already has an object named '" ~ name ~ "'");
  }
}

/// Generic interactor of a maintained resource. Subclasses map the input
/// onto the entity (fromInput/toInput) and add reference checks.
abstract class ResourceInteractor(TEntity, TId, TInput) : DspInteractor, IManageResource!(TEntity, TId, TInput) {
  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected abstract IDspRepository!(TEntity, TId) store();
  /// "Connection" (messages)
  protected abstract string what();
  /// "connection" (audit entries)
  protected abstract string eventPrefix();
  protected abstract TInput toInput(const TEntity e);
  /// Map (parse, check references); creating = false for updates.
  protected abstract void fromInput(TenantId t, ref TEntity e, TInput input, bool creating);

  /// Input members that cannot change after creation.
  protected string[] immutableAttributes() {
    return null;
  }

  /// Checks after mapping and validation, before saving (cross-entity rules).
  protected void beforeSave(TenantId t, ref TEntity e, bool creating) {
  }

  /// Reference checks and cascades (inside the batch of the removal).
  protected void beforeRemove(TenantId t, const TEntity e, UserId actor) {
  }

  TEntity create(CreateCommand!TInput c) {
    auto id = idOrNew(c.id, what ~ " ID");
    if (store.existsById(c.tenantId, TId(id)))
      throw DspException.conflict(what ~ " '" ~ id ~ "' already exists");
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
        throw DspException.invalid("'" ~ apiName(name) ~ "' of " ~ what.toLower ~ " '" ~ c.id ~ "' cannot be changed");
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

///
unittest {
  assert(apiName("continue_") == "continue" && apiName("name") == "name");
  assert(["S4_ORDERS"].containsName("s4_orders") && !["A"].containsName("B"));
}
