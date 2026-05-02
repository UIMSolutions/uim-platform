module uim.platform.service.infrastructure.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class TenantRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  protected TEntity[TId][TenantId] store;

  this() {
    initialize();
  }

  bool initialize(Json initData = Json(null)) {
    return true;
  }

  size_t countAll() {
    return findAll().length;
  }

  TEntity[] findAll(size_t offset = 0, size_t limit = 0) {
    return store.byValue.array.skip(offset).limit(limit);
  }

  void removeAll() {
    findAll().each!(e => remove(e));
  }

  // #region ById
  bool existsById(TId id) {
    return findAll().any!(e => e.id == id);
  }

  bool existsAllById(TId[] ids) {
    return ids.all!(id => existsById(id));
  }

  TEntity findById(TId id) {
    foreach (tenantId, entities; store) {
      if (id in entities)
        return entities[id];
    }
    return TEntity.init;
  }

  TEntity[] findAllById(TId[] ids) {
    return ids.filter!(id => existsById(id))
      .map!(id => findById(id))
      .array;
  }

  void removeById(TId id, bool deleteTenantIfEmpty = false) {
    auto entity = findById(id);
    if (!entity.isNull)
      return;

    remove(entity, deleteTenantIfEmpty);
  }

  void removeAllById(TId[] ids, bool deleteTenantIfEmpty = false) {
    ids.each!(id => removeById(id, deleteTenantIfEmpty));
  }

  bool existsById(TenantId tenantId, TId id) {
    return existsByTenant(tenantId) && (id in store[tenantId]);
  }

  bool existsAllById(TenantId tenantId, TId[] ids) {
    return ids.all!(id => existsById(tenantId, id));
  }

  TEntity findById(TenantId tenantId, TId id) {
    if (tenantId in store && id in store[tenantId]) {
      return store[tenantId][id];
    }
    return TEntity.init;
  }

  TEntity[] findAllById(TenantId tenantId, TId[] ids) {
    return ids.filter!(id => existsById(tenantId, id))
      .map!(id => findById(tenantId, id))
      .array;
  }

  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false) {
    if (existsById(tenantId, id)) {
      store[tenantId].remove(id);

      if (deleteTenantIfEmpty && store[tenantId].empty) {
        store.remove(tenantId);
      }
    }
  }

  void removeAllById(TenantId tenantId, TId[] ids, bool deleteTenantIfEmpty = false) {
    ids.each!(id => removeById(tenantId, id, deleteTenantIfEmpty));
  }
  // #endregion ById

  size_t countAll() {
    return findAll.length;
  }

  TEntity[] findAll(size_t offset = 0, size_t limit = 0) {
    TEntity[] allItems = store.byValue.map!(entities => entities.values).array.flat;

    return limit == 0
      ? allItems.skip(offset).array : allItems.skip(offset).take(limit);

  }

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store ? true : false;
  }

  size_t countByTenant(TEntity[] items, TenantId tenantId) {
    return filterByTenant(items, tenantId).length;
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  TEntity[] filterByTenant(TEntity[] items, TenantId tenantId) {
    return items.filter!(e => e.tenantId == tenantId).array;
  }

  TEntity[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 0) {
    if (!existsByTenant(tenantId)) {
      return null;
    }

    TEntity[] allItems;
    uint idx;
    foreach (item; store[tenantId].values.array) {
      if (idx >= offset && (limit == 0 || allItems.length < limit))
        allItems ~= item;
      idx++;
    }
    return allItems;
  }

  void removeByTenant(TenantId tenantId, bool deleteTenantIfEmpty = false) {
    findByTenant(tenantId).each!(e => remove(e, deleteTenantIfEmpty));
  }

  void save(TEntity item) {
    if (!existsByTenant(item.tenantId)) {
      TEntity[TId] entities;
      store[item.tenantId] = entities;
    }
    store[item.tenantId][item.id] = item;
  }

  void saveAll(TEntity[] items) {
    items.each!(item => save(item));
  }

  void update(TEntity item) {
    if (existsById(item.tenantId, item.id)) {
      store[item.tenantId][item.id] = item;
    }
  }

  void updateAll(TEntity[] items) {
    items.each!(item => update(item));
  }

  void remove(TEntity item, bool deleteTenantIfEmpty = false) {
    removeById(item.tenantId, item.id, deleteTenantIfEmpty);
  }

  void removeAll(TEntity[] items, bool deleteTenantIfEmpty = false) {
    items.each!(item => remove(item, deleteTenantIfEmpty));
  }
}
