module uim.platform.service.infrastructure.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class IdRepository(TEntity, TId) : IIdRepository!(TEntity, TId) {
  protected TEntity[TId] store;

  bool existsById(TId id) {
    return (id in store) !is null;
  }

  TEntity findById(TId id) {
    auto entity = id in store;
    return entity is null ? TEntity.init : *entity;
  }

  TEntity[] findAll() {
    return store.byValue.array;
  }

  void save(TEntity item) {
    store[item.id] = item;
  }

  void update(TEntity item) {
    auto existing = item.id in store;
    if (existing !is null) {
      *existing = item;
    }
  }

  void remove(TId id) {
    store.remove(id);
  }
}

unittest {
  import uim.platform.service.infrastructure.repositories.id;

  struct SampleEntity {
    string id;
    string value;
  }

  auto repo = new IdRepository!(SampleEntity, string)();

  assert(!repo.existsById("missing"));
  assert(repo.findById("missing") == SampleEntity.init);

  repo.save(SampleEntity("item-123", "Test Item"));
  assert(repo.existsById("item-123"));

  auto saved = repo.findById("item-123");
  assert(saved.id == "item-123");
  assert(saved.value == "Test Item");

  repo.update(SampleEntity("item-123", "Updated Item"));
  auto updated = repo.findById("item-123");
  assert(updated.value == "Updated Item");

  repo.update(SampleEntity("missing", "no-op"));
  assert(!repo.existsById("missing"));

  auto all = repo.findAll();
  assert(all.length == 1);
  assert(all[0].id == "item-123");

  repo.remove("item-123");
  assert(!repo.existsById("item-123"));

  repo.remove("item-123");
}
