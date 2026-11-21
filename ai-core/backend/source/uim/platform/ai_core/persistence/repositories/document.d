/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repositories over a document collection.
module uim.platform.ai_core.persistence.repositories.document;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

private void sortByCreation(E)(ref E[] entities) {
  entities.sort!((a, b) => a.createdAt != b.createdAt ? a.createdAt < b.createdAt : a.id.value < b.id.value);
}

/// Tenant wide aggregates (key = id).
class TenantDocumentRepository(TEntity, TId, alias toRecord, alias fromRecord) : ITenantWideRepository!(TEntity, TId) {
  protected IDocumentStore store;
  protected string collection;

  this(IDocumentStore store, string collection) {
    this.store = store;
    this.collection = collection;
  }

  TEntity[] findAll(TenantId t) {
    TEntity[] entities;
    foreach (doc; store.all(collection, t.value))
      entities ~= fromRecord(doc);
    sortByCreation(entities);
    return entities;
  }

  TEntity findById(TenantId t, TId id) {
    if (id.isNull)
      return TEntity.init;
    auto doc = store.get(collection, t.value, id.value);
    return doc.type == Json.Type.object ? fromRecord(doc) : TEntity.init;
  }

  bool existsById(TenantId t, TId id) {
    return !id.isNull && store.get(collection, t.value, id.value).type == Json.Type.object;
  }

  size_t countAll(TenantId t) {
    return store.count(collection, t.value);
  }

  void save(TEntity entity) {
    store.put(collection, entity.tenantId.value, entity.id.value, toRecord(entity));
  }

  bool removeById(TenantId t, TId id) {
    return store.remove(collection, t.value, id.value);
  }
}

/// Aggregates inside a resource group (key = "<resourceGroupId>~<id>").
class GroupDocumentRepository(TEntity, TId, alias toRecord, alias fromRecord) : IGroupRepository!(TEntity, TId) {
  protected IDocumentStore store;
  protected string collection;

  this(IDocumentStore store, string collection) {
    this.store = store;
    this.collection = collection;
  }

  TEntity[] findAll(TenantId t) {
    TEntity[] entities;
    foreach (doc; store.all(collection, t.value))
      entities ~= fromRecord(doc);
    sortByCreation(entities);
    return entities;
  }

  TEntity[] findByGroup(TenantId t, ResourceGroupId rg) {
    auto all = findAll(t);
    return rg.isNull ? all : all.filter!(e => e.resourceGroupId == rg).array;
  }

  TEntity findById(TenantId t, ResourceGroupId rg, TId id) {
    if (id.isNull || rg.isNull)
      return TEntity.init;
    auto doc = store.get(collection, t.value, resourceKey(rg.value, id.value));
    return doc.type == Json.Type.object ? fromRecord(doc) : TEntity.init;
  }

  bool existsById(TenantId t, ResourceGroupId rg, TId id) {
    return !findById(t, rg, id).isNull;
  }

  size_t countAll(TenantId t) {
    return store.count(collection, t.value);
  }

  void save(TEntity entity) {
    store.put(collection, entity.tenantId.value, resourceKey(entity.resourceGroupId.value, entity.id.value), toRecord(entity));
  }

  bool removeById(TenantId t, ResourceGroupId rg, TId id) {
    return store.remove(collection, t.value, resourceKey(rg.value, id.value));
  }

  size_t removeByGroup(TenantId t, ResourceGroupId rg) {
    size_t removed;
    foreach (e; findByGroup(t, rg))
      if (removeById(t, rg, e.id))
        removed++;
    return removed;
  }

  /// Entities of a group matching a predicate (creation order).
  protected TEntity[] where(TenantId t, ResourceGroupId rg, scope bool delegate(const TEntity) @safe predicate) {
    TEntity[] result;
    foreach (e; findByGroup(t, rg))
      if (predicate(e))
        result ~= e;
    return result;
  }
}
