/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Common behaviour of the resource interactors: result mapping, parent
/// lookups, uniqueness checks and event publishing.
module uim.platform.object_store.application.usecases.base;

import uim.platform.object_store;

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
  catch (ObjectStoreException e)
    return UsecaseResult(false, "", e.msg, e.status);
}

/// Base class of the aggregate interactors.
///
/// Subclasses supply `TEntity build(TCreate)` (validated, not yet saved) and
/// `void apply(ref TEntity, TSpec)`; optionally `beforeRemove` (dependency
/// checks), `afterCreate`, `afterUpdate` and `afterRemove` (cascades, progress).
abstract class ResourceUseCase(TEntity, TId, TCreate, TUpdate) : IManageResource!(TEntity, TId, TCreate, TUpdate) {
  alias TSpec = typeof(TUpdate.init.spec);

  protected ObjectStoreRepositories repos;
  protected EventRecorder events;
  protected ITenantRepository!(TEntity, TId) repo;
  protected string kindLabel;
  protected string topic;

  this(ObjectStoreRepositories repos, ITenantRepository!(TEntity, TId) repo, EventRecorder events,
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
      throw new ObjectStoreNotFoundException(kindLabel ~ " '" ~ id.value ~ "' not found");
    return entity;
  }

  /// The bucket of a child aggregate; it must exist.
  protected Bucket requireBucket(TenantId tenantId, BucketId id) {
    validate(!id.isEmpty, "bucketId is required");
    auto bucket = repos.buckets.findById(tenantId, id);
    if (bucket.isNull)
      throw new ObjectStoreNotFoundException("Bucket '" ~ id.value ~ "' not found");
    return bucket;
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

/// Base class of the aggregates that belong to a bucket (policies, lifecycle
/// rules, CORS rules, bindings): the parent must exist, names are unique per
/// bucket and fixed after creation, bucket id and name are copied on create.
/// Subclasses add their rules in `check`.
abstract class BucketChildUseCase(TEntity, TId, TCreate, TUpdate) : ResourceUseCase!(TEntity, TId, TCreate, TUpdate) {
  protected IBucketChildRepository!(TEntity, TId) children;

  this(ObjectStoreRepositories repos, IBucketChildRepository!(TEntity, TId) children, EventRecorder events,
      string kindLabel, string topic) {
    super(repos, children, events, kindLabel, topic);
    this.children = children;
  }

  /// Business rules of the aggregate (validate / normalize).
  protected void check(ref TEntity entity, const Bucket bucket) {
  }

  override protected TEntity build(TCreate r) {
    auto bucket = requireBucket(r.tenantId, r.parentId);
    auto e = TEntity(r.tenantId);
    assignMatching(e, r.spec);
    e.bucketId = bucket.id;
    e.bucketName = bucket.name;
    e.name = e.name.strip;
    validateDisplayName(kindLabel, e.name);
    check(e, bucket);
    ensureUnique(children.findByName(r.tenantId, bucket.id, e.name), e, "bucket '" ~ bucket.name ~ "'");
    return e;
  }

  override protected void apply(ref TEntity e, TSpec spec) {
    assignMatching(e, spec, ["name"]);
    check(e, requireBucket(e.tenantId, e.bucketId));
  }

  /// The children of a bucket (sorted by name).
  TEntity[] listByBucket(TenantId tenantId, BucketId bucketId) {
    return children.findByBucket(tenantId, bucketId);
  }
}

/// Decode the content of an ObjectSpec.
const(ubyte)[] decodeContent(string content, ContentEncoding encoding) {
  final switch (encoding) {
  case ContentEncoding.text:
    return cast(const(ubyte)[]) content;
  case ContentEncoding.base64:
    import std.base64 : Base64;

    try
      return Base64.decode(content.strip);
    catch (Exception e)
      throw new ObjectStoreValidationException("content is not valid base64: " ~ e.msg);
  }
}
