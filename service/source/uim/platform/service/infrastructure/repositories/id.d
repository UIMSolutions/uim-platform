module uim.platform.service.infrastructure.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class IdRepository(TEntity, TId) {
    protected TEntity[TId] store;

    bool existsById(TId id) {
        return id in store ? true : false;
    }

    TEntity findById(TId id) {
        return id in store ? store[id] : TEntity.init;
    }

  void save(TEntity item) {
    store[item.id] = item;
  }

  void update(TEntity item) {
    if (item.id in store) {
      store[item.id] = item;
    }
  }

  void remove(TId id) {
    if (id in store) {
      store.remove(id);
    }
  }
}
