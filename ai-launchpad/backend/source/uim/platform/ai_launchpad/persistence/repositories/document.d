/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repository over a document collection (key = id).
module uim.platform.ai_launchpad.persistence.repositories.document;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class DocumentRepository(TEntity, TId) : IAilpRepository!(TEntity, TId) {
  protected IDocumentStore store;
  protected string collection;

  this(IDocumentStore store, string collection) {
    this.store = store;
    this.collection = collection;
  }

  TEntity[] findAll(TenantId t) {
    return mapped(store.all(collection, t.value));
  }

  TEntity findById(TenantId t, TId id) {
    if (id.isNull)
      return TEntity.init;
    auto doc = store.get(collection, t.value, id.value);
    return doc.type == Json.Type.object ? recordToEntity!(TEntity, TId)(doc) : TEntity.init;
  }

  bool existsById(TenantId t, TId id) {
    return !id.isNull && store.get(collection, t.value, id.value).type == Json.Type.object;
  }

  size_t countAll(TenantId t) {
    return store.count(collection, t.value);
  }

  TEntity[] findByReference(TenantId t, string attribute, string value) {
    return mapped(matching(t, attribute, value));
  }

  size_t countByReference(TenantId t, string attribute, string value) {
    return matching(t, attribute, value).length;
  }

  void save(TEntity entity) {
    store.put(collection, entity.tenantId.value, entity.id.value, entityToRecord(entity));
  }

  bool removeById(TenantId t, TId id) {
    return store.remove(collection, t.value, id.value);
  }

  size_t removeByReference(TenantId t, string attribute, string value) {
    size_t n;
    foreach (doc; matching(t, attribute, value))
      if (store.remove(collection, t.value, textField(doc, "id")))
        n++;
    return n;
  }

  /// Remove the records whose numeric attribute is below the cut-off.
  protected size_t removeBefore(TenantId t, string attribute, long cutoff) {
    size_t n;
    foreach (doc; store.all(collection, t.value))
      if (longField(doc, attribute) < cutoff && store.remove(collection, t.value, textField(doc, "id")))
        n++;
    return n;
  }

  protected Json[] matching(TenantId t, string attribute, string value) {
    Json[] docs;
    foreach (doc; store.all(collection, t.value))
      if (textField(doc, attribute) == value)
        docs ~= doc;
    return docs;
  }

  /// Creation order (then id): stable lists for UI, CLI and tests.
  protected TEntity[] mapped(Json[] docs) {
    TEntity[] entities;
    foreach (doc; docs)
      entities ~= recordToEntity!(TEntity, TId)(doc);
    entities.sort!((a, b) => a.createdAt != b.createdAt ? a.createdAt < b.createdAt : a.id.value < b.id.value);
    return entities;
  }
}
