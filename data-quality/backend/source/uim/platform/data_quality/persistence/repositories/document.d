/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repositories over a document collection.
module uim.platform.data_quality.persistence.repositories.document;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

private void sortByCreation(E)(ref E[] entities) {
  entities.sort!((a, b) => a.createdAt != b.createdAt ? a.createdAt < b.createdAt : a.id.value < b.id.value);
}

/// Tenant wide aggregates (key = id).
class TenantDocumentRepository(TEntity, TId, alias toRecord, alias fromRecord) : IDqTenantRepository!(TEntity, TId) {
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

/// Resources inside a dataset (key = "<datasetId>~<id>"). Dataset filters
/// look at the raw "datasetId" of the documents before mapping them.
class ScopedDocumentRepository(TEntity, TId, alias toRecord, alias fromRecord) : IDqScopedRepository!(TEntity, TId) {
  protected IDocumentStore store;
  protected string collection;

  this(IDocumentStore store, string collection) {
    this.store = store;
    this.collection = collection;
  }

  TEntity[] findAll(TenantId t) {
    return findByDataset(t, DatasetId.init);
  }

  TEntity[] findByDataset(TenantId t, DatasetId ds) {
    TEntity[] entities;
    foreach (doc; store.all(collection, t.value))
      if (ds.isNull || textField(doc, "datasetId") == ds.value)
        entities ~= fromRecord(doc);
    sortByCreation(entities);
    return entities;
  }

  TEntity findById(TenantId t, DatasetId ds, TId id) {
    if (id.isNull || ds.isNull)
      return TEntity.init;
    auto doc = store.get(collection, t.value, resourceKey(ds.value, id.value));
    return doc.type == Json.Type.object ? fromRecord(doc) : TEntity.init;
  }

  bool existsById(TenantId t, DatasetId ds, TId id) {
    return !id.isNull && !ds.isNull && store.get(collection, t.value, resourceKey(ds.value, id.value)).type == Json.Type.object;
  }

  size_t countAll(TenantId t) {
    return store.count(collection, t.value);
  }

  size_t countByDataset(TenantId t, DatasetId ds) {
    if (ds.isNull)
      return countAll(t);
    size_t n;
    foreach (doc; store.all(collection, t.value))
      if (textField(doc, "datasetId") == ds.value)
        n++;
    return n;
  }

  void save(TEntity entity) {
    store.put(collection, entity.tenantId.value, resourceKey(entity.datasetId.value, entity.id.value), toRecord(entity));
  }

  bool removeById(TenantId t, DatasetId ds, TId id) {
    return store.remove(collection, t.value, resourceKey(ds.value, id.value));
  }

  size_t removeByDataset(TenantId t, DatasetId ds) {
    size_t removed;
    foreach (doc; store.all(collection, t.value))
      if (textField(doc, "datasetId") == ds.value && store.remove(collection, t.value, resourceKey(ds.value, textField(doc, "id"))))
        removed++;
    return removed;
  }

  /// Entities of a dataset matching a raw document predicate (creation order).
  protected TEntity[] whereDocument(TenantId t, scope bool delegate(Json) @safe predicate) {
    TEntity[] entities;
    foreach (doc; store.all(collection, t.value))
      if (predicate(doc))
        entities ~= fromRecord(doc);
    sortByCreation(entities);
    return entities;
  }
}
