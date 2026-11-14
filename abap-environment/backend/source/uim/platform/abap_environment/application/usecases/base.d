/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Common behaviour of the resource interactors: result mapping, parent lookups,
/// uniqueness checks and event publishing.
module uim.platform.abap_environment.application.usecases.base;

import uim.platform.abap_environment;

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
  catch (AbapException e)
    return UsecaseResult(false, "", e.msg, e.status);
}

/// Base class of the aggregate interactors.
///
/// Subclasses supply `TEntity build(TCreate)` (validated, not yet saved) and
/// `void apply(ref TEntity, TSpec)`; optionally `beforeRemove` (dependency
/// checks) and `retire` (soft delete: change state instead of removing).
abstract class ResourceUseCase(TEntity, TId, TCreate, TUpdate) : IManageResource!(TEntity, TId, TCreate, TUpdate) {
  alias TSpec = typeof(TUpdate.init.spec);

  protected AbapRepositories repos;
  protected IAbapEventPublisher publisher;
  protected ITenantRepository!(TEntity, TId) repo;
  protected string kindLabel;
  protected string topic;

  this(AbapRepositories repos, ITenantRepository!(TEntity, TId) repo, IAbapEventPublisher publisher,
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

  /// Return true after changing `entity` into a "being deleted" state; the
  /// entity is then updated instead of removed (the reconciler finishes).
  protected bool retire(ref TEntity entity) {
    return false;
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
      publish(entity, "created");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' created");
    });
  }

  UsecaseResult update(TUpdate request) {
    return guarded(() {
      auto entity = require(request.tenantId, request.id);
      apply(entity, request.spec);
      entity.update(request.actor);
      repo.update(entity);
      publish(entity, "updated");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' updated");
    });
  }

  UsecaseResult remove(TenantId tenantId, TId id, UserId actor) {
    return guarded(() {
      auto entity = require(tenantId, id);
      beforeRemove(entity);
      if (retire(entity)) {
        entity.update(actor);
        repo.update(entity);
        publish(entity, "deletion-requested");
        return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' is being deleted");
      }
      repo.remove(entity);
      publish(entity, "deleted");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' deleted");
    });
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Apply a state change (actions such as suspend, publish, lock, release).
  protected UsecaseResult transition(TenantId tenantId, TId id, UserId actor, string verb,
      scope void delegate(ref TEntity) @safe change) {
    return guarded(() {
      auto entity = require(tenantId, id);
      change(entity);
      entity.update(actor);
      repo.update(entity);
      publish(entity, verb);
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' " ~ verb);
    });
  }

  protected TEntity require(TenantId tenantId, TId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      throw new AbapNotFoundException(kindLabel ~ " '" ~ id.value ~ "' not found");
    return entity;
  }

  /// The parent system; it must exist and not be on its way out.
  protected SystemInstance requireSystem(TenantId tenantId, SystemInstanceId id, string field = "systemInstanceId") {
    validate(!id.isEmpty, field ~ " is required");
    auto system = repos.systems.findById(tenantId, id);
    if (system.isNull)
      throw new AbapNotFoundException("System '" ~ id.value ~ "' not found");
    ensureState(system.status != SystemStatus.deleting, "System '" ~ system.name ~ "' is being deleted");
    return system;
  }

  /// The active parent system (development, users and jobs need a running system).
  protected SystemInstance requireActiveSystem(TenantId tenantId, SystemInstanceId id, string forWhat) {
    auto system = requireSystem(tenantId, id);
    requireActive(system, forWhat);
    return system;
  }

  /// Names are unique within their scope: `existing` is the entity found by name.
  protected void ensureUnique(const TEntity existing, const TEntity candidate, string scope_) {
    ensureState(existing.isNull || existing.id == candidate.id,
      kindLabel ~ " '" ~ candidate.name ~ "' already exists in " ~ scope_);
  }

  protected void publish(TEntity entity, string verb) {
    auto payload = Json.emptyObject;
    payload["tenantId"] = entity.tenantId.value;
    payload["id"] = entity.id.value;
    payload["name"] = entity.name;
    payload["systemInstanceId"] = systemOf(entity).value;
    publisher.publish(topic ~ "." ~ verb, payload);
  }
}
