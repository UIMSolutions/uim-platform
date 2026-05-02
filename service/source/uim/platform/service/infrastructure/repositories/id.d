module uim.platform.service.infrastructure.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class IdRepository(TEntity, TId) : IIdRepository!(TEntity, TId) {
  protected TEntity[TId] store;

  this() {
    initialize();
  }

  bool initialize(Json initData = Json(null)) {
    return true;
  }

  bool exists(TEntity entity) {
    return store.byValue.any!(e => e == entity);
  }

  @disable
  size_t indexOf(TEntity entity);

  size_t countAll() {
    return findAll().length;
  }

  TEntity[] findAll(size_t offset = 0, size_t limit = 0) {
    return store.byValue.array.skip(offset).limit(limit);
  }

  void removeAll() {
    store.clear();
  }

  
  bool existsById(TId id) {
    return (id in store) ? true : false;
  }

  TEntity findById(TId id) {
    if (id in store) {
      return store[id];
    }
    return TEntity.init;
  }

  void removeById(TId id) {
    auto e = findById(id);
    remove(e);
  }

  bool existsAllById(TId[] ids) {
    return ids.all!(id => existsById(id));
  }

  TEntity[] findAllById(TId[] ids, bool onlyExisting = true) {
    return onlyExisting
      ? ids.filter!(id => existsById(id))
      .map!(id => findById(id))
      .array : ids.map!(id => findById(id)).array;
  }

  void removeAllById(TId[] ids) {
    findAllById(ids).each!(e => remove(e));
  }

  void save(TEntity entity) {
    store[entity.id] = entity;
  }

  void update(TEntity entity) {
    if (existsById(entity.id)) {
      store[entity.id] = entity;
    }
  }

  void remove(TEntity entity) {
    if (existsById(entity.id)) {
      store.remove(entity.id);
    }
  }

  void saveAll(TEntity[] entities) {
    entities.each!(entity => save(entity));
  }

  void updateAll(TEntity[] entities) {
    entities.each!(entity => update(entity));
  }

  void removeAll(TEntity[] entities) {
    entities.each!(entity => remove(entity));
  }
}
