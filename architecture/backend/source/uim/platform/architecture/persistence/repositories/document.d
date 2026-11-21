/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repository over a document collection (key = entity id).
module uim.platform.architecture.persistence.repositories.document;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class DocumentRepository(TEntity, TId, alias toRecord, alias fromRecord) : IArchitectureRepository!(TEntity, TId) {
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
    entities.sort!((a, b) => a.createdAt != b.createdAt ? a.createdAt < b.createdAt : a.id.value < b.id.value);
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
