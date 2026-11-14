/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repository over a document collection.
module uim.platform.authorization.persistence.repositories.document;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class DocumentRepository(TEntity, TId, alias toRecord, alias fromRecord) : IEntityRepository!(TEntity, TId) {
  protected IDocumentStore store;
  protected string collection;

  this(IDocumentStore store, string collection) {
    this.store = store;
    this.collection = collection;
  }

  TEntity[] findAll(TenantId tenantId) {
    TEntity[] entities;
    foreach (doc; store.all(collection, tenantId.value))
      entities ~= fromRecord(doc);
    entities.sort!((a, b) => a.createdAt != b.createdAt ? a.createdAt < b.createdAt : a.id.value < b.id.value);
    return entities;
  }

  TEntity findById(TenantId tenantId, TId id) {
    if (id.isNull)
      return TEntity.init;
    auto doc = store.get(collection, tenantId.value, id.value);
    return doc.type == Json.Type.object ? fromRecord(doc) : TEntity.init;
  }

  bool existsById(TenantId tenantId, TId id) {
    return !id.isNull && store.get(collection, tenantId.value, id.value).type == Json.Type.object;
  }

  size_t countAll(TenantId tenantId) {
    return store.count(collection, tenantId.value);
  }

  void save(TEntity entity) {
    store.put(collection, entity.tenantId.value, entity.id.value, toRecord(entity));
  }

  bool removeById(TenantId tenantId, TId id) {
    return store.remove(collection, tenantId.value, id.value);
  }

  protected TEntity[] where(TenantId tenantId, scope bool delegate(const TEntity) @safe predicate) {
    TEntity[] result;
    foreach (e; findAll(tenantId))
      if (predicate(e))
        result ~= e;
    return result;
  }

  protected TEntity first(TenantId tenantId, scope bool delegate(const TEntity) @safe predicate) {
    foreach (e; findAll(tenantId))
      if (predicate(e))
        return e;
    return TEntity.init;
  }
}
