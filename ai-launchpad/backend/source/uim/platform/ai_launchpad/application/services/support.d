/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors: the policy, auditing, references and
/// the generic resource interactor (create / PATCH / get / list / delete
/// with validation, immutable attributes and audit entries).
module uim.platform.ai_launchpad.application.services.support;

import std.traits : FieldNameTuple;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct AilpPolicy {
  int maxFailedLogins = 5; /// failed logins before a temporary lock
  long lockSeconds = 900; /// duration of the temporary lock
  size_t minPasswordLength = 10;
  long logRetentionDays = 30; /// audit log entries are purged afterwards
  size_t maxReconcileBatch = 500; /// executions and deployments per reconcile run
}

/// API name of an input member ("version_" → "version": D keywords).
string apiName(string member) pure {
  return member.length > 1 && member[$ - 1] == '_' ? member[0 .. $ - 1] : member;
}

/// Actor of the reconcile worker and of the start-up.
enum string systemActor = "system";

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw AilpException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw AilpException.invalid("Tenant is required");
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

/// Base class of all interactors: repositories, clock, audit trail, unit of work and policy.
abstract class AilpInteractor {
  protected AilpRepositories repos;
  protected IClock clock;
  protected IAuditTrail audit;
  protected IAilpUnitOfWork unitOfWork;
  protected AilpPolicy policy;
  private long lastTime; /// strictly increasing creation times keep lists in order

  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.audit = audit !is null ? audit : new NullAuditTrail;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateAilpUnitOfWork;
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

  protected void emit(string type, TenantId t, UserId actor, string subject, Json data = Json.emptyObject) {
    audit.record(type, t, actor, subject, data);
  }

  protected void batch(scope void delegate() @safe work) {
    unitOfWork.batch(work);
  }

  /// Refuse an operation while references exist ("… is still used by 3 configurations").
  protected void requireUnused(string what, long count, string users) {
    if (count > 0)
      throw AilpException.ruleViolation(format("%s is still used by %d %s", what, count, users));
  }

  // ── references ─────────────────────────────────────────────────────────
  protected Workspace workspaceOf(TenantId t, string id) {
    auto w = id.strip;
    if (w.length == 0)
      throw AilpException.invalid("Workspace is required");
    return required(repos.workspaces.findById(t, WorkspaceId(w)), "Workspace '" ~ w ~ "'");
  }

  protected Connection connectionOf(TenantId t, string id) {
    auto c = id.strip;
    if (c.length == 0)
      throw AilpException.invalid("Connection is required");
    return required(repos.connections.findById(t, ConnectionId(c)), "Connection '" ~ c ~ "'");
  }

  protected Scenario scenarioOf(TenantId t, string id) {
    auto s = id.strip;
    if (s.length == 0)
      throw AilpException.invalid("Scenario is required");
    return required(repos.scenarios.findById(t, ScenarioId(s)), "Scenario '" ~ s ~ "'");
  }

  protected Configuration configurationOf(TenantId t, string id) {
    auto c = id.strip;
    if (c.length == 0)
      throw AilpException.invalid("Configuration is required");
    return required(repos.configurations.findById(t, ConfigurationId(c)), "Configuration '" ~ c ~ "'");
  }

  /// The requested resource group (or the default one of the connection);
  /// it must belong to the connection and be ready.
  protected ResourceGroup resourceGroupFor(TenantId t, const Connection c, string requested, string operation) {
    auto id = requested.strip.length ? requested.strip : c.defaultResourceGroup;
    if (id.length == 0)
      throw AilpException.invalid("Resource group is required (connection '" ~ c.id.value ~ "' has no default)");
    auto g = required(repos.resourceGroups.findById(t, ResourceGroupId(id)), "Resource group '" ~ id ~ "'");
    if (g.connectionId != c.id)
      throw AilpException.ruleViolation("Resource group '" ~ id ~ "' belongs to connection '" ~ g.connectionId.value
          ~ "', not to '" ~ c.id.value ~ "'");
    g.requireReady(operation);
    return g;
  }
}

/// Generic interactor of a maintained resource. Subclasses map the input
/// onto the entity (fromInput/toInput) and add reference checks.
abstract class ResourceInteractor(TEntity, TId, TInput) : AilpInteractor, IManageResource!(TEntity, TId, TInput) {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected abstract IAilpRepository!(TEntity, TId) store();
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

  /// Validation of the entity (default: e.validate()).
  protected void check(TenantId t, const TEntity e) {
    static if (__traits(compiles, e.validate()))
      e.validate();
  }

  /// Checks after mapping and validation, before saving (cross-entity rules).
  protected void beforeSave(TenantId t, ref TEntity e, bool creating, const string[] changed) {
  }

  /// Reference checks and cascades (inside the batch of the removal).
  protected void beforeRemove(TenantId t, const TEntity e, UserId actor) {
  }

  TEntity create(CreateCommand!TInput c) {
    auto id = idOrNew(c.id, what ~ " ID");
    if (store.existsById(c.tenantId, TId(id)))
      throw AilpException.conflict(what ~ " '" ~ id ~ "' already exists");
    TInput input;
    c.input.applyTo(input);
    TEntity e;
    stampCreated!(TEntity, TId)(e, c.tenantId, c.actor, id, nextTime);
    fromInput(c.tenantId, e, input, true);
    check(c.tenantId, e);
    beforeSave(c.tenantId, e, true, c.input.fields);
    store.save(e);
    emit(eventPrefix ~ ".created", c.tenantId, c.actor, id);
    return e;
  }

  TEntity update(UpdateCommand!TInput c) @trusted {
    auto e = get(c.tenantId, TId(c.id));
    auto before = toInput(e);
    auto after = before;
    c.changes.applyTo(after);
    auto fixed = immutableAttributes;
    string[] changed;
    static foreach (name; FieldNameTuple!TInput) {
      if (__traits(getMember, after, name) != __traits(getMember, before, name)) {
        if (fixed.canFind(name))
          throw AilpException.invalid("'" ~ apiName(name) ~ "' of " ~ what.toLower ~ " '" ~ c.id ~ "' cannot be changed");
        changed ~= name;
      }
    }
    fromInput(c.tenantId, e, after, false);
    check(c.tenantId, e);
    beforeSave(c.tenantId, e, false, changed);
    stampUpdated(e, c.actor, now);
    store.save(e);
    emit(eventPrefix ~ ".updated", c.tenantId, c.actor, c.id, Json(["fields": Json(c.changes.fields.map!apiName.join(","))]));
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
    emit(eventPrefix ~ ".deleted", t, actor, id.value);
  }
}

///
unittest {
  assert(apiName("version_") == "version" && apiName("name") == "name");
}
