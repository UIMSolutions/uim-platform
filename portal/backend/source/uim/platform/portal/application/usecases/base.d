/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Common behaviour of the resource interactors: result mapping, lookups of
/// parents, module requirements, event publishing and cluster synchronisation.
module uim.platform.portal.application.usecases.base;

import uim.platform.portal;

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
  catch (PortalException e)
    return UsecaseResult(false, "", e.msg, e.status);
}

/// Validate that a JSON text is empty or a JSON object.
void validateJsonObject(string what, string text) {
  if (text.strip.length == 0)
    return;
  Json parsed;
  try
    parsed = parseJsonString(text);
  catch (Exception e)
    throw new PortalValidationException(what ~ " is not valid JSON: " ~ e.msg);
  validate(parsed.type == Json.Type.object, what ~ " must be a JSON object");
}

/// Base class of the aggregate interactors.
///
/// TSpecific supplies: `TEntity build(TCreate)`, `void apply(ref TEntity, TSpec)`,
/// `Json render(TEntity)` and optionally `void beforeRemove(TEntity)`.
abstract class ResourceUseCase(TEntity, TId, TCreate, TUpdate) : IManageResource!(TEntity, TId, TCreate, TUpdate) {
  alias TSpec = typeof(TUpdate.init.spec);

  protected PortalRepositories repos;
  protected IPortalEventPublisher publisher;
  protected IClusterGateway cluster;
  protected ITenantRepository!(TEntity, TId) repo;
  protected string kindLabel;
  protected string topic;

  this(PortalRepositories repos, ITenantRepository!(TEntity, TId) repo, IPortalEventPublisher publisher,
      IClusterGateway cluster, string kindLabel, string topic) {
    this.repos = repos;
    this.repo = repo;
    this.publisher = publisher;
    this.cluster = cluster;
    this.kindLabel = kindLabel;
    this.topic = topic;
  }

  // ── hooks ──────────────────────────────────────────────────────────────

  /// Create a validated entity (not yet saved).
  protected abstract TEntity build(TCreate request);
  /// Apply a spec to an existing entity and validate it.
  protected abstract void apply(ref TEntity entity, TSpec spec);
  /// The Kubernetes manifest (Json(null) if the kind has none).
  protected abstract Json render(TEntity entity);
  /// Called before an entity is removed (dependency checks, cascades).
  protected void beforeRemove(TEntity entity) {
  }

  // ── queries ────────────────────────────────────────────────────────────

  TEntity get(TenantId tenantId, TId id) {
    return repo.findById(tenantId, id);
  }

  TEntity[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Json manifest(TenantId tenantId, TId id) {
    auto entity = get(tenantId, id);
    return entity.isNull ? Json(null) : render(entity);
  }

  // ── commands ───────────────────────────────────────────────────────────

  UsecaseResult create(TCreate request) {
    return guarded(() {
      validate(!request.tenantId.isEmpty, "Tenant ID is required");
      auto entity = build(request);
      entity.createdBy = request.actor;
      entity.updatedBy = request.actor;
      repo.save(entity);
      synchronize(entity, "created");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' created");
    });
  }

  UsecaseResult update(TUpdate request) {
    return guarded(() {
      auto entity = require(request.tenantId, request.id);
      apply(entity, request.spec);
      entity.update(request.actor);
      repo.update(entity);
      synchronize(entity, "updated");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' updated");
    });
  }

  UsecaseResult remove(TenantId tenantId, TId id, UserId actor) {
    return guarded(() {
      auto entity = require(tenantId, id);
      beforeRemove(entity);
      auto manifest = render(entity);
      repo.remove(entity);
      if (manifest.type == Json.Type.object)
        cluster.remove(environmentOf(entity), manifest["kind"].get!string,
          fieldString(manifest["metadata"], "namespace"), entity.name);
      publish(entity, "deleted");
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' deleted");
    });
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Apply a state change to an entity (actions such as pause, stop, connect).
  protected UsecaseResult transition(TenantId tenantId, TId id, UserId actor, string verb,
      scope void delegate(ref TEntity) @safe change) {
    return guarded(() {
      auto entity = require(tenantId, id);
      change(entity);
      entity.update(actor);
      repo.update(entity);
      synchronize(entity, verb);
      return succeeded(entity.id.value, kindLabel ~ " '" ~ entity.name ~ "' " ~ verb);
    });
  }

  protected TEntity require(TenantId tenantId, TId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      throw new PortalNotFoundException(kindLabel ~ " '" ~ id.value ~ "' not found");
    return entity;
  }

  protected KymaEnvironment requireEnvironment(TenantId tenantId, KymaEnvironmentId id) {
    validate(!id.isEmpty, "environmentId is required");
    auto env = repos.environments.findById(tenantId, id);
    if (env.isNull)
      throw new PortalNotFoundException("Environment '" ~ id.value ~ "' not found");
    ensureState(env.status != EnvironmentStatus.error, "Environment '" ~ env.name ~ "' is in error state");
    return env;
  }

  protected KymaNamespace requireNamespace(TenantId tenantId, NamespaceId id) {
    validate(!id.isEmpty, "namespaceId is required");
    auto ns = repos.namespaces.findById(tenantId, id);
    if (ns.isNull)
      throw new PortalNotFoundException("Namespace '" ~ id.value ~ "' not found");
    ensureState(ns.status == NamespaceStatus.active, "Namespace '" ~ ns.name ~ "' is terminating");
    return ns;
  }

  /// The module a workload kind needs must be active in the environment.
  protected void requireModule(TenantId tenantId, KymaEnvironmentId environmentId, WorkloadKind kind) {
    auto type = requiredModuleFor(kind);
    auto active = repos.modules.findByEnvironment(tenantId, environmentId)
      .any!(m => m.moduleType == type && m.status.isActive);
    ensureState(active, "The '" ~ enumText(type) ~ "' module must be enabled in the environment first");
  }

  protected static KymaEnvironmentId environmentOf(TEntity entity) {
    static if (is(TEntity == KymaEnvironment))
      return entity.id;
    else
      return entity.environmentId;
  }

  /// Apply the manifest to the cluster and publish a domain event.
  protected void synchronize(TEntity entity, string verb) {
    auto manifest = render(entity);
    if (manifest.type == Json.Type.object)
      cluster.apply(environmentOf(entity), manifest);
    publish(entity, verb);
  }

  protected void publish(TEntity entity, string verb) {
    auto payload = Json.emptyObject;
    payload["tenantId"] = entity.tenantId.value;
    payload["id"] = entity.id.value;
    payload["name"] = entity.name;
    payload["environmentId"] = environmentOf(entity).value;
    publisher.publish(topic ~ "." ~ verb.replace(" ", "-"), payload);
  }
}
