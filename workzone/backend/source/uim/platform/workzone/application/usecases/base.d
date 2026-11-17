/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.base;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Successful result.
UsecaseResult succeeded(string id, string message = "OK") {
  return UsecaseResult(true, id, message, 200);
}

/// Run `action` and map business exceptions to a failed UsecaseResult whose
/// `code` is the exception status (404, 409, 422).
UsecaseResult guarded(scope UsecaseResult delegate() @safe action) {
  try
    return action();
  catch (WorkzoneException e)
    return UsecaseResult(false, "", e.msg, e.status);
}

/// Base class of the aggregate interactors (common behaviour: result mapping,
/// parent and reference lookups, uniqueness checks and event publishing).
///
/// Subclasses supply `TEntity build(TCreate)` (validated, not yet saved) and
/// `void apply(ref TEntity, TSpec)`; optionally `beforeRemove` (dependency
/// checks), `afterCreate` (feed entries) and `afterRemove` (cascades).
abstract class ResourceUseCase(TEntity, TId, TCreate, TUpdate) : IManageResource!(TEntity, TId, TCreate, TUpdate) {
  alias TSpec = typeof(TUpdate.init.spec);

  protected WorkzoneRepositories repos;
  protected IWorkzoneEventPublisher publisher;
  protected IWorkzoneRepository!(TEntity, TId) repo;
  protected string kindLabel;
  protected string topic;

  this(WorkzoneRepositories repos, IWorkzoneRepository!(TEntity, TId) repo, IWorkzoneEventPublisher publisher,
      string kindLabel, string topic) {
    this.repos = repos;
    this.repo = repo;
    this.publisher = publisher;
    this.kindLabel = kindLabel;
    this.topic = topic;
  }

  // ── hooks ──────────────────────────────────────────────────────────────

  protected abstract TEntity build(TCreate request);
  protected abstract void apply(ref TEntity entity, TSpec spec);

  /// Throw if the entity must not be removed (dependents, wrong status).
  protected void beforeRemove(TEntity entity) {
  }

  /// Called after the entity was saved for the first time.
  protected void afterCreate(TEntity entity, UserId actor) {
  }

  /// Called after the entity was removed (cascades).
  protected void afterRemove(TEntity entity) {
  }

  // ── queries ────────────────────────────────────────────────────────────

  TEntity get(TenantId tenantId, TId id) {
    return repo.findById(tenantId, id);
  }

  TEntity[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  // ── commands ───────────────────────────────────────────────────────────

  UsecaseResult create(TCreate request) {
    return guarded(() {
      validate(!request.tenantId.isEmpty, "Tenant ID is required");
      auto entity = build(request);
      entity.createdBy = request.actor;
      entity.updatedBy = request.actor;
      repo.save(entity);
      afterCreate(entity, request.actor);
      announce(entity, "created");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ nameOf(entity) ~ "' created");
    });
  }

  UsecaseResult update(TUpdate request) {
    return guarded(() {
      auto entity = require(request.tenantId, request.id);
      apply(entity, request.spec);
      entity.update(request.actor);
      repo.update(entity);
      announce(entity, "updated");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ nameOf(entity) ~ "' updated");
    });
  }

  UsecaseResult remove(TenantId tenantId, TId id, UserId actor) {
    return guarded(() {
      auto entity = require(tenantId, id);
      beforeRemove(entity);
      repo.remove(entity);
      afterRemove(entity);
      announce(entity, "deleted");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ nameOf(entity) ~ "' deleted");
    });
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Apply a state change (publish, archive, complete, ...).
  protected UsecaseResult transition(TenantId tenantId, TId id, UserId actor, string verb,
      scope void delegate(ref TEntity) @safe change) {
    return guarded(() {
      auto entity = require(tenantId, id);
      change(entity);
      entity.update(actor);
      repo.update(entity);
      announce(entity, verb);
      return succeeded(entity.id.value, kindLabel ~ " '" ~ nameOf(entity) ~ "' " ~ verb);
    });
  }

  protected TEntity require(TenantId tenantId, TId id) {
    auto entity = repo.findById(tenantId, id);
    ensureFound(!entity.isNull, kindLabel ~ " '" ~ id.value ~ "' not found");
    return entity;
  }

  /// The parent workspace; it must exist and accept new `what`.
  protected Workspace requireWorkspace(TenantId tenantId, WorkspaceId id, string what) {
    validate(!id.isEmpty, "workspaceId is required");
    auto ws = repos.workspaces.findById(tenantId, id);
    ensureFound(!ws.isNull, "Workspace '" ~ id.value ~ "' not found");
    ensureAcceptsContent(ws, what);
    return ws;
  }

  /// A workspace by id (Workspace.init if missing).
  protected Workspace workspaceById(TenantId tenantId, WorkspaceId id) {
    return repos.workspaces.findById(tenantId, id);
  }

  /// Role names; all must exist.
  protected string[] requireRoles(TenantId tenantId, const string[] names) {
    auto result = normalizedNames(names);
    foreach (n; result)
      ensureFound(!repos.roles.findByName(tenantId, n).isNull, "Role '" ~ n ~ "' not found");
    return result;
  }

  /// Display names are unique per tenant: `existing` is the aggregate found by name.
  protected void ensureUnique(const TEntity existing, const TEntity candidate, string scope_ = "this tenant") {
    ensureState(existing.isNull || existing.id == candidate.id,
      kindLabel ~ " '" ~ nameOf(candidate) ~ "' already exists in " ~ scope_);
  }

  /// Display names are unique per workspace.
  protected void ensureUniqueInWorkspace(const TEntity candidate, string workspaceName) {
    auto ws = workspaceOf(candidate);
    auto name = nameOf(candidate);
    auto clashes = repo.findMatching(candidate.tenantId,
      (const TEntity e) => e.id != candidate.id && workspaceOf(e) == ws && nameOf(e) == name);
    ensureState(clashes.length == 0, kindLabel ~ " '" ~ name ~ "' already exists in workspace " ~ workspaceName);
  }

  protected void announce(TEntity entity, string verb) {
    auto payload = Json.emptyObject;
    payload["tenantId"] = entity.tenantId.value;
    payload["id"] = entity.id.value;
    payload["name"] = nameOf(entity);
    payload["workspaceId"] = workspaceOf(entity).value;
    publisher.publish(topic ~ "." ~ verb, payload);
  }
}
