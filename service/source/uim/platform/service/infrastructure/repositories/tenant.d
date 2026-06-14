module uim.platform.service.infrastructure.repositories.tenant;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

class TenantRepository(TEntity, TId) : BaseRepository!(TEntity), ITenantRepository!(TEntity, TId) {
  protected TEntity[TId][TenantId] store;

  this() {
    super();
  }

  override bool initialize(Json initData = Json(null)) {
    if (!super.initialize(initData)) {
      return false;
    }

    return true;
  }

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store ? true : false;
  }

  bool isTenantEmpty(TenantId tenantId) {
    return !existsByTenant(tenantId) || store[tenantId].empty;
  }

  TenantId[] findAllTenants() {
    return store.byKey.array;
  }

  void createTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId)) {
      TEntity[TId] entities;
      store[tenantId] = entities;
    }
  }

  override bool exists(TEntity entity) {
    return existsById(entity.tenantId, entity.id);
  }

  override size_t indexOf(TEntity entity) {
    size_t idx = 0;
    foreach (item; findByTenant(entity.tenantId)) {
      if (item.tenantId == entity.tenantId && item.id == entity.id) {
        return idx;
      }
      idx++;
    }
    return size_t.max;
  }

  override size_t countAll() {
    return findAll().length;
  }

  override TEntity[] findAll(size_t offset = 0, size_t limit = 0) {
    auto tenants = findAllTenants();
    auto tenantsItems = tenants.map!(tenantId => store[tenantId].values.array).array.flat();
    return limit == 0
      ? tenantsItems.skip(offset) : tenantsItems.skip(offset).take(limit);
  }

  override void removeAll() {
    findAll().each!(e => remove(e));
  }

  // #region ById
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

  void removeById(TenantId tenantId, TId id) {
    if (existsById(tenantId, id)) {
      store[tenantId].remove(id);
    }
  }

  void removeAllById(TenantId tenantId, TId[] ids) {
    ids.each!(id => removeById(tenantId, id));
  }
  // #endregion ById

  size_t countByTenant(TEntity[] items, TenantId tenantId) {
    return filterByTenant(items, tenantId).length;
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  TEntity[] filterByTenant(TEntity[] items, TenantId tenantId) {
    return items.filter!(e => e.tenantId == tenantId).array;
  }

  TEntity[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
    if (!existsByTenant(tenantId)) {
      return null;
    }

    TEntity[] allItems;
    size_t idx;
    foreach (item; store[tenantId].values.array) {
      if (idx >= offset && (limit == 0 || allItems.length < limit))
        allItems ~= item;
      idx++;
    }
    return allItems;
  }

  void removeByTenant(TenantId tenantId) {
    findByTenant(tenantId).each!(e => remove(e));
  }

  override void save(TEntity item) {
    if (!existsByTenant(item.tenantId)) {
      TEntity[TId] entities;
      store[item.tenantId] = entities;
    }
    store[item.tenantId][item.id] = item;
  }

  override void saveAll(TEntity[] items) {
    items.each!(item => save(item));
  }

  override void update(TEntity item) {
    if (existsById(item.tenantId, item.id)) {
      store[item.tenantId][item.id] = item;
    }
  }

  override void updateAll(TEntity[] items) {
    items.each!(item => update(item));
  }

  override void remove(TEntity item) {
    removeById(item.tenantId, item.id);
  }

  override void removeAll(TEntity[] items) {
    items.each!(item => remove(item));
  }
}
///

struct TestEntityId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TestEntity {
  TestEntityId id;
  string name;
  TenantId tenantId;

  bool opEquals(TestEntity other) const {
    return id == other.id && name == other.name && tenantId == other.tenantId;
  }
}

class TestRepository : TenantRepository!(TestEntity, TestEntityId) {
}

unittest {
  TestEntity entity1 = TestEntity(TestEntityId("1"), "Entity 1", TenantId("tenant1"));
  TestEntity entity2 = TestEntity(TestEntityId("2"), "Entity 2", TenantId("tenant1"));

  auto repo = new TestRepository();
  repo.save(entity1);
  repo.save(entity2);

  assert(repo.exists(entity1));
  assert(repo.existsById(entity1.tenantId, entity1.id));
  assert(repo.countAll() == 2);

  repo.remove(entity1);
  assert(!repo.exists(entity1));
  // writeln("Count after removal: ", repo.countAll());
  assert(repo.countAll() == 1);
}
