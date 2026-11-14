/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Common behaviour of the resource interactors: result mapping, parent and
/// catalogue lookups, uniqueness checks and event publishing.
module uim.platform.application_studio.application.usecases.base;

import uim.platform.application_studio;

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
  catch (StudioException e)
    return UsecaseResult(false, "", e.msg, e.status);
}

/// Base class of the aggregate interactors.
///
/// Subclasses supply `TEntity build(TCreate)` (validated, not yet saved) and
/// `void apply(ref TEntity, TSpec)`; optionally `beforeRemove` (dependency
/// checks), `retire` (soft delete: change state instead of removing) and
/// `afterRemove` (cascades).
abstract class ResourceUseCase(TEntity, TId, TCreate, TUpdate) : IManageResource!(TEntity, TId, TCreate, TUpdate) {
  alias TSpec = typeof(TUpdate.init.spec);

  protected StudioRepositories repos;
  protected IStudioEventPublisher publisher;
  protected ITenantRepository!(TEntity, TId) repo;
  protected string kindLabel;
  protected string topic;

  this(StudioRepositories repos, ITenantRepository!(TEntity, TId) repo, IStudioEventPublisher publisher,
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
      afterRemove(entity);
      publish(entity, "deleted");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' deleted");
    });
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Apply a state change (start, stop, connect, build, ...).
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
      throw new StudioNotFoundException(kindLabel ~ " '" ~ id.value ~ "' not found");
    return entity;
  }

  /// The parent dev space; it must exist and not be on its way out.
  protected DevSpace requireDevSpace(TenantId tenantId, DevSpaceId id) {
    validate(!id.isEmpty, "devSpaceId is required");
    auto ds = repos.devSpaces.findById(tenantId, id);
    if (ds.isNull)
      throw new StudioNotFoundException("Dev space '" ~ id.value ~ "' not found");
    ensureState(ds.status != DevSpaceStatus.deleting, "Dev space '" ~ ds.name ~ "' is being deleted");
    return ds;
  }

  /// The parent project; it must exist and not be archived.
  protected Project requireProject(TenantId tenantId, ProjectId id, string forWhat) {
    validate(!id.isEmpty, "projectId is required");
    auto p = repos.projects.findById(tenantId, id);
    if (p.isNull)
      throw new StudioNotFoundException("Project '" ~ id.value ~ "' not found");
    ensureState(p.status != ProjectStatus.archived, "Project '" ~ p.name ~ "' is archived — restore it to " ~ forWhat);
    return p;
  }

  /// A dev space type by id.
  protected DevSpaceType requireType(TenantId tenantId, DevSpaceTypeId id) {
    validate(!id.isEmpty, "devSpaceTypeId is required");
    auto t = repos.devSpaceTypes.findById(tenantId, id);
    if (t.isNull)
      throw new StudioNotFoundException("Dev space type '" ~ id.value ~ "' not found");
    return t;
  }

  /// Catalogue extensions by name; all must exist (404). With `forNewUse`,
  /// inactive and deprecated extensions are rejected (409).
  protected Extension[] requireExtensions(TenantId tenantId, const string[] names, bool forNewUse) {
    Extension[] result;
    foreach (n; names) {
      auto e = repos.extensions.findByName(tenantId, n);
      if (e.isNull)
        throw new StudioNotFoundException("Extension '" ~ n ~ "' not found in the catalogue");
      if (forNewUse)
        ensureState(e.status == ExtensionStatus.active, "Extension '" ~ n ~ "' is " ~ enumText(e.status)
            ~ " and cannot be added");
      result ~= e;
    }
    return result;
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
    payload["devSpaceId"] = devSpaceOf(entity).value;
    publisher.publish(topic ~ "." ~ verb, payload);
  }
}
