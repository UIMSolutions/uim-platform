/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.manage.systems;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Interactor: connector configuration of source, target or proxy systems.
///
/// Rules: names are unique per role; the system type must support the role;
/// URL and credentials are validated per type; changing the connection of an
/// active system requires a new test (status → configuring); systems used by
/// jobs or transformations cannot be deleted.
class ManageSystemsUseCase(TEntity, TId)
  : ResourceUseCase!(TEntity, TId, CreateSystemRequest, UpdateRequest!(TId, SystemSpec)),
  IManageSystemsUseCase!(TEntity, TId) {

  protected ISystemRepository!(TEntity, TId) systems;
  protected IIdentityConnector connector;
  protected SystemRole role;

  this(ProvisioningRepositories repos, ISystemRepository!(TEntity, TId) systems, EventRecorder events,
      IIdentityConnector connector, SystemRole role) {
    auto label = role == SystemRole.source ? "Source system" : role == SystemRole.target ? "Target system" : "Proxy system";
    super(repos, systems, events, label, "provisioning." ~ enumText(role) ~ "System");
    this.systems = systems;
    this.connector = connector;
    this.role = role;
  }

  override protected TEntity build(CreateSystemRequest r) {
    auto e = TEntity(r.tenantId);
    assignMatching(e, r.spec);
    e.status = SystemStatus.configuring;
    check(e);
    return e;
  }

  override protected void apply(ref TEntity e, SystemSpec spec) {
    auto before = endpoint(e);
    assignMatching(e, spec);
    check(e);
    if (e.status == SystemStatus.active && endpoint(e) != before) {
      e.status = SystemStatus.configuring;
      e.statusMessage = "Connection changed — test and activate again";
    }
  }

  /// The settings that require a new connection test when changed
  /// (connector properties do not).
  protected static string[] endpoint(const TEntity e) {
    return [enumText(e.systemType), e.url, enumText(e.authenticationType), e.user, e.password];
  }

  protected void check(ref TEntity e) {
    validateDisplayName(kindLabel, e.name);
    validate(e.description.length <= 1000, "Description must not exceed 1000 characters");
    e.url = validateConnection(e.connection, role).url;
    ensureUnique(systems.findByName(e.tenantId, e.name), e, "this tenant");
  }

  override protected void beforeRemove(TEntity e) {
    auto users = repos.transformations.findBySystem(e.tenantId, role, e.id.value);
    ensureState(users.length == 0, kindLabel ~ " '" ~ e.name ~ "' is used by transformation '" ~ (users.length
        ? users[0].name : "") ~ "'");
    auto jobs = jobsOf(e);
    ensureState(jobs.length == 0, kindLabel ~ " '" ~ e.name ~ "' is used by job '" ~ (jobs.length ? jobs[0].name : "") ~ "'");
  }

  override protected void afterUpdate(TEntity before, TEntity after, UserId actor) {
    if (before.name == after.name)
      return;
    // keep the denormalized names of jobs and transformations in sync
    foreach (t; repos.transformations.findBySystem(after.tenantId, role, after.id.value)) {
      t.systemName = after.name;
      repos.transformations.update(t);
    }
    foreach (j; jobsOf(after)) {
      static if (is(TEntity == SourceSystem))
        j.sourceSystemName = after.name;
      else static if (is(TEntity == TargetSystem))
        j.targetSystemName = after.name;
      j.name = j.name.replace(before.name, after.name);
      repos.jobs.update(j);
    }
  }

  protected ProvisioningJob[] jobsOf(TEntity e) {
    static if (is(TEntity == SourceSystem))
      return repos.jobs.findBySource(e.tenantId, e.id);
    else static if (is(TEntity == TargetSystem))
      return repos.jobs.findByTarget(e.tenantId, e.id);
    else
      return null;
  }

  // ── actions ────────────────────────────────────────────────────────────

  /// Run the connector test and record the outcome on the entity.
  protected ConnectionTestResult probe(ref TEntity e) {
    ConnectionTestResult result;
    try
      result = connector.test(e.connection);
    catch (ConnectorException ex)
      result = ConnectionTestResult(false, ex.msg);
    e.lastTestedAt = nowStdTime();
    e.statusMessage = result.message;
    return result;
  }

  UsecaseResult activate(TenantId tenantId, TId id, UserId actor) {
    return guarded(() {
      auto e = require(tenantId, id);
      ensureState(e.status != SystemStatus.active, kindLabel ~ " '" ~ e.name ~ "' is already active");
      auto result = probe(e);
      e.status = result.success ? SystemStatus.active : SystemStatus.error;
      e.update(actor);
      repo.update(e);
      publish(e, result.success ? "activated" : "failed");
      if (!result.success)
        return UsecaseResult(false, e.id.value, "Connection test of '" ~ e.name ~ "' failed: " ~ result.message, 409);
      return succeeded(e.id.value, kindLabel ~ " '" ~ e.name ~ "' activated (" ~ result.message ~ ")");
    });
  }

  UsecaseResult deactivate(TenantId tenantId, TId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref e) {
      ensureState(e.status != SystemStatus.inactive, kindLabel ~ " '" ~ e.name ~ "' is already inactive");
      e.status = SystemStatus.inactive;
      e.statusMessage = "Deactivated";
    });
  }

  UsecaseResult testConnection(TenantId tenantId, TId id, UserId actor) {
    return guarded(() {
      auto e = require(tenantId, id);
      auto result = probe(e);
      if (!result.success)
        e.status = SystemStatus.error;
      else if (e.status == SystemStatus.error)
        e.status = SystemStatus.active; // recovered
      e.update(actor);
      repo.update(e);
      publish(e, "tested");
      return succeeded(e.id.value, "Connection test of '" ~ e.name ~ "': " ~ (result.success ? "OK" : "FAILED")
          ~ " — " ~ result.message);
    });
  }

  TEntity findByName(TenantId tenantId, string name) {
    return systems.findByName(tenantId, name);
  }
}

alias ManageSourceSystemsUseCase = ManageSystemsUseCase!(SourceSystem, SourceSystemId);
alias ManageTargetSystemsUseCase = ManageSystemsUseCase!(TargetSystem, TargetSystemId);
alias ManageProxySystemsUseCase = ManageSystemsUseCase!(ProxySystem, ProxySystemId);
