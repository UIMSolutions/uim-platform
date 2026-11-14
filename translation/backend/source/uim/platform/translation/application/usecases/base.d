/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Common behaviour of the resource interactors: result mapping, parent
/// lookups, uniqueness checks and event publishing.
module uim.platform.translation.application.usecases.base;

import uim.platform.translation;

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
  catch (TranslationException e)
    return UsecaseResult(false, "", e.msg, e.status);
}

/// Base class of the aggregate interactors.
///
/// Subclasses supply `TEntity build(TCreate)` (validated, not yet saved) and
/// `void apply(ref TEntity, TSpec)`; optionally `beforeRemove` (dependency
/// checks), `afterCreate`, `afterUpdate` and `afterRemove` (cascades, progress).
abstract class ResourceUseCase(TEntity, TId, TCreate, TUpdate) : IManageResource!(TEntity, TId, TCreate, TUpdate) {
  alias TSpec = typeof(TUpdate.init.spec);

  protected TranslationRepositories repos;
  protected EventRecorder events;
  protected ITenantRepository!(TEntity, TId) repo;
  protected string kindLabel;
  protected string topic;

  this(TranslationRepositories repos, ITenantRepository!(TEntity, TId) repo, EventRecorder events,
      string kindLabel, string topic) {
    this.repos = repos;
    this.repo = repo;
    this.events = events;
    this.kindLabel = kindLabel;
    this.topic = topic;
  }

  // ── hooks ──────────────────────────────────────────────────────────────

  protected abstract TEntity build(TCreate request);
  protected abstract void apply(ref TEntity entity, TSpec spec);

  protected void beforeRemove(TEntity entity) {
  }

  protected void afterCreate(TEntity entity, UserId actor) {
  }

  protected void afterUpdate(TEntity before, TEntity after, UserId actor) {
  }

  protected void afterRemove(TEntity entity, UserId actor) {
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
      afterCreate(entity, request.actor);
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' created");
    });
  }

  UsecaseResult update(TUpdate request) {
    return guarded(() {
      auto entity = require(request.tenantId, request.id);
      auto before = entity;
      apply(entity, request.spec);
      entity.update(request.actor);
      repo.update(entity);
      publish(entity, "updated");
      afterUpdate(before, entity, request.actor);
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' updated");
    });
  }

  UsecaseResult remove(TenantId tenantId, TId id, UserId actor) {
    return guarded(() {
      auto entity = require(tenantId, id);
      beforeRemove(entity);
      repo.remove(entity);
      publish(entity, "deleted");
      afterRemove(entity, actor);
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' deleted");
    });
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Apply a state change (actions such as activate, archive, cancel).
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
      throw new TranslationNotFoundException(kindLabel ~ " '" ~ id.value ~ "' not found");
    return entity;
  }

  /// The project of a text or job; it must exist.
  protected TranslationProject requireProject(TenantId tenantId, TranslationProjectId id) {
    validate(!id.isEmpty, "projectId is required");
    auto project = repos.projects.findById(tenantId, id);
    if (project.isNull)
      throw new TranslationNotFoundException("Translation project '" ~ id.value ~ "' not found");
    return project;
  }

  /// Uniqueness within a scope: `existing` is the entity found by its key.
  protected void ensureUnique(const TEntity existing, const TEntity candidate, string scope_) {
    ensureState(existing.isNull || existing.id == candidate.id,
      kindLabel ~ " '" ~ candidate.name ~ "' already exists in " ~ scope_);
  }

  protected void publish(TEntity entity, string verb) {
    auto payload = Json.emptyObject;
    payload["tenantId"] = entity.tenantId.value;
    payload["id"] = entity.id.value;
    payload["name"] = entity.name;
    events.publish(topic ~ "." ~ verb, payload);
  }
}
