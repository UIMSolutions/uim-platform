/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors: the policy, auditing, reference
/// checks and the generic resource interactor (create / PATCH / get / list
/// / delete with validation, immutable attributes and events).
module uim.platform.data_retention.application.services.support;

import std.traits : FieldNameTuple;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct DrPolicy {
  bool processRequestsImmediately; /// process deletion requests on creation (no background worker)
  bool runJobsImmediately; /// run archiving jobs that are due on creation (no background worker)
  int maxFailedLogins = 5; /// failed logins before a temporary lock
  long lockSeconds = 900; /// duration of the temporary lock
  size_t minPasswordLength = 10;
}

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw DataRetentionException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw DataRetentionException.invalid("Tenant is required");
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
abstract class DrInteractor {
  protected DrRepositories repos;
  protected IClock clock;
  protected IDrEventPublisher events;
  protected IDrUnitOfWork unitOfWork;
  protected DrPolicy policy;

  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateDrUnitOfWork;
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

  // ── references ──────────────────────────────────────────────────────────

  protected ApplicationGroup applicationGroupOf(TenantId t, string id) {
    if (id.strip.length == 0)
      throw DataRetentionException.invalid("Application group is required");
    return required(repos.applicationGroups.findById(t, ApplicationGroupId(id.strip)), "Application group '" ~ id ~ "'");
  }

  protected BusinessPurpose businessPurposeOf(TenantId t, string id) {
    if (id.strip.length == 0)
      throw DataRetentionException.invalid("Business purpose is required");
    return required(repos.businessPurposes.findById(t, BusinessPurposeId(id.strip)), "Business purpose '" ~ id ~ "'");
  }

  protected LegalGround legalGroundOf(TenantId t, string id) {
    if (id.strip.length == 0)
      throw DataRetentionException.invalid("Legal ground is required");
    return required(repos.legalGrounds.findById(t, LegalGroundId(id.strip)), "Legal ground '" ~ id ~ "'");
  }

  protected DataSubject dataSubjectOf(TenantId t, DataSubjectId id) {
    if (id.isNull)
      throw DataRetentionException.invalid("Data subject is required");
    return required(repos.dataSubjects.findById(t, id), "Data subject '" ~ id.value ~ "'");
  }

  /// The legal ground of a new rule; the business purpose is optional but
  /// must match the legal ground's if given.
  protected LegalGround ruleTargetOf(TenantId t, string purpose, string ground) {
    auto g = legalGroundOf(t, ground);
    if (purpose.strip.length && purpose.strip != g.businessPurposeId.value)
      throw DataRetentionException.invalid("Legal ground '" ~ g.id.value ~ "' belongs to business purpose '"
          ~ g.businessPurposeId.value ~ "', not to '" ~ purpose.strip ~ "'");
    return g;
  }

  /// An optional reference: "" stays empty, anything else must exist.
  protected string optionalReference(TId, R)(R repo, TenantId t, string id, string what) {
    auto v = id.strip;
    if (v.length == 0)
      return "";
    if (!repo.existsById(t, TId(v)))
      throw DataRetentionException.notFound(what ~ " '" ~ v ~ "'");
    return v;
  }

  /// Refuse an operation while references exist ("… is used by 3 data subjects").
  protected void requireUnused(string what, long count, string users) {
    if (count > 0)
      throw DataRetentionException.ruleViolation(format("%s is still used by %d %s", what, count, users));
  }

  /// Active legal grounds of a purpose with an active residence rule
  /// (optionally not counting one legal ground).
  protected long completeLegalGrounds(TenantId t, BusinessPurposeId purpose, LegalGroundId excluded = LegalGroundId.init) {
    long n;
    auto residence = repos.residenceRules.findByReference(t, "businessPurposeId", purpose.value);
    foreach (g; repos.legalGrounds.findByReference(t, "businessPurposeId", purpose.value))
      if (g.active && g.id != excluded && residence.canFind!(r => r.active && r.legalGroundId == g.id))
        n++;
    return n;
  }

  /// An active purpose must keep at least one complete legal ground.
  protected void requirePurposeStaysComplete(TenantId t, BusinessPurposeId purpose, LegalGroundId excluded, string change) {
    auto p = repos.businessPurposes.findById(t, purpose);
    if (!p.isNull && p.isActive && completeLegalGrounds(t, purpose, excluded) == 0)
      throw DataRetentionException.ruleViolation("Business purpose '" ~ purpose.value ~ "' is active and would have no "
          ~ "legal ground with a residence rule left — deactivate it before " ~ change);
  }
}

/// Generic interactor of a maintained resource. Subclasses map the input
/// onto the entity (fromInput/toInput) and add reference checks.
abstract class ResourceInteractor(TEntity, TId, TInput) : DrInteractor, IManageResource!(TEntity, TId, TInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected abstract IDrRepository!(TEntity, TId) store();
  /// "Application group" (messages)
  protected abstract string what();
  /// "applicationGroup" (events)
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

  /// Derived attributes of returned entities (e.g. retention evaluation).
  protected TEntity[] decorate(TenantId t, TEntity[] entities) {
    return entities;
  }

  protected final TEntity decorateOne(TenantId t, TEntity e) {
    return decorate(t, [e])[0];
  }

  TEntity create(CreateCommand!TInput c) {
    auto id = idOrNew(c.id, what ~ " ID");
    if (store.existsById(c.tenantId, TId(id)))
      throw DataRetentionException.conflict(what ~ " '" ~ id ~ "' already exists");
    TInput input;
    c.input.applyTo(input);
    TEntity e;
    stampCreated!(TEntity, TId)(e, c.tenantId, c.actor, id, now);
    fromInput(c.tenantId, e, input, true);
    e.validate();
    store.save(e);
    emit(eventPrefix ~ ".created", c.tenantId, id);
    return decorateOne(c.tenantId, e);
  }

  TEntity update(UpdateCommand!TInput c) @trusted {
    auto e = get(c.tenantId, TId(c.id));
    auto before = toInput(e);
    auto after = before;
    c.changes.applyTo(after);
    auto fixed = immutableAttributes;
    static foreach (name; FieldNameTuple!TInput)
      if (fixed.canFind(name) && __traits(getMember, after, name) != __traits(getMember, before, name))
        throw DataRetentionException.invalid("'" ~ name ~ "' of " ~ what.toLower ~ " '" ~ c.id ~ "' cannot be changed");
    fromInput(c.tenantId, e, after, false);
    e.validate();
    stampUpdated(e, c.actor, now);
    store.save(e);
    emit(eventPrefix ~ ".updated", c.tenantId, c.id, Json(["fields": Json(c.changes.fields.join(","))]));
    return decorateOne(c.tenantId, e);
  }

  TEntity get(TenantId t, TId id) {
    return decorateOne(t, required(store.findById(t, id), what ~ " '" ~ id.value ~ "'"));
  }

  TEntity[] list(TenantId t) {
    return decorate(t, store.findAll(t));
  }

  void remove(TenantId t, TId id, UserId actor) {
    auto e = required(store.findById(t, id), what ~ " '" ~ id.value ~ "'");
    batch(() {
      beforeRemove(t, e, actor);
      store.removeById(t, id);
    });
    emit(eventPrefix ~ ".deleted", t, id.value, Json(["by": Json(actor.value)]));
  }
}
