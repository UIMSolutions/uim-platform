module uim.platform.service.infrastructure.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class IdRepository(TEntity, TId) : IIdRepository!(TEntity, TId) {
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
// ///
// unittest {
//   import uim.platform.service.domain.ports.repositories.id;
//   import uim.platform.service.infrastructure.repositories.id;

//   IdRepository!(string, string) repo;

//   string id = "item-123";
//   string value = "Test Item";

//   // Test save and findById
//   repo.save((id, value));
//   assert(repo.existsById(id));
//   assert(repo.findById(id).id == id);
//   assert(repo.findById(id).value == value);

//   // Test update
//   string newValue = "Updated Item";
//   repo.update((id, newValue));
//   assert(repo.findById(id).value == newValue);

//   // Test remove
//   repo.remove(id);
//   assert(!repo.existsById(id));
// }