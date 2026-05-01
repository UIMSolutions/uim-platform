module uim.platform.service.infrastructure.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class IdRepository(TEntity, TId) : IIdRepository!(TEntity, TId) {
  protected TEntity[TId] store;

  TEntity[] findAll() {
    return store.byValue.array;
  }

  bool existsById(TId id) {
    return (id in store) !is null;
  }
  bool existsAllById(TId[] ids) {
    return ids.all!(id => existsById(id));
  }

  TEntity findById(TId id) {
    auto entity = id in store;
    return entity is null ? TEntity.init : *entity;
  }
  TEntity[] findAllById(TId[] ids) {
    return ids.map!(id => findById(id)).array;
  }

  void removeById(TId id) {
    store.removeById(id);
  }
  void removeAllById(TId[] ids) {
    ids.each!(id => removeById(id));
  }

  void save(TEntity entity) {
    store[entity.id] = entity;
  }

  void saveAll(TEntity[] entities) {
    entities.each!(entity => save(entity));
  }

  void update(TEntity entity) {
    if (existsById(entity.id)) {
      store[entity.id] = entity;
    }
  }

  void updateAll(TEntity[] entities) {
    entities.each!(entity => update(entity));
  }
  
  void remove(TEntity entity) {
    store.remove(entity.id);
  }

  void removeAll(TEntity[] entities) {
    entities.each!(entity => remove(entity));
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

  repo.remove(SampleEntity("item-123", "Test Item"));
  assert(!repo.existsById("item-123"));

  repo.remove(SampleEntity("item-123", "Test Item"));
}
