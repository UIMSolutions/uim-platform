module uim.platform.service.infrastructure.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class TenantRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  protected ITenantStore!(TEntity, TId) _store;

  this() {
    initialize();
  }

  this(ITenantStore!(TEntity, TId) store) {
    initialize();
    _store = store;
  }

  bool initialize(Json initData = Json(null)) {
    // if (!super.initialize(initData)) {
    //   return false;
    // }

    _store = new MemoryTenantStore!(TEntity, TId)();
    return true;
  }

  // bool existsByTenant(TenantId tenantId) {
  //   return _store.exists(tenantId);
  // }

  // bool isTenantEmpty(TenantId tenantId) {
  //   return !existsByTenant(tenantId) || _store[tenantId].empty;
  // }

  // TenantId[] findAllTenants() {
  //   return store.byKey.array;
  // }

  // void createTenant(TenantId tenantId) {
  //   if (!existsByTenant(tenantId)) {
  //     TEntity[TId] entities;
  //     _store[tenantId] = entities;
  //   }
  // }

    // #region exists
    bool existsByTenant(TenantId tenantId) {
        return _store.exists(tenantId);
    }
    bool existsById(TenantId tenantId, TId id) {
        return _store.exists(tenantId, id);
    }
    bool exists(TEntity entity) {
        return _store.exists(entity);
    }
    // #endregion exists

     // #region count
    size_t countByTenant(TenantId tenantId) {
        return _store.count(tenantId);
    }
    size_t countByTenant(TenantId tenantId, bool delegate(TEntity) @safe predicate) {
        return _store.count(tenantId, predicate);
    }
    // #endregion count

    bool isEmpty(TenantId tenantId) {
        return _store.isEmpty(tenantId);
    }

    // #region filter
    TEntity[] filter(TEntity[] entities, bool delegate(TEntity) @safe predicate) {
        return _store.filter(entities, predicate);
    }
    // #endregion filter

    // #region find
    TEntity[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        return _store.find(tenantId, offset, limit);
    }
    TEntity findById(TenantId tenantId, TId id) {
        return _store.find(tenantId, id);
    }
    // #endregion find

    // #region save
    void save(TEntity entity) {
        _store.save(entity);
    }
    void save(TEntity[] entities) {
        foreach (entity; entities) {
            _store.save(entity);
        }
    }
    // #endregion save

    // #region update
    void update(TEntity entity) {
        _store.update(entity);
    }
    void update(TEntity[] entities) {
        foreach (entity; entities) {
            _store.update(entity);
        }
    }
    // #endregion update

    // #region remove
    void removeByTenant(TenantId tenantId) {
        _store.remove(tenantId);
    }

    void removeById(TenantId tenantId, TId id) {
        _store.remove(tenantId, id);
    }
    
    void remove(TEntity entity) {
        _store.remove(entity);
    }
    void remove(TEntity[] entities) {
        foreach (entity; entities) {
            _store.remove(entity);
        }
    }
    // #endregion remove
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
  assert(repo.exists(entity1.tenantId, entity1.id));
  assert(repo.count(entity1.tenantId) == 2);

  repo.remove(entity1);
  assert(!repo.exists(entity1));
  // writeln("Count after removal: ", repo.countAll());
  assert(repo.count(entity1.tenantId) == 1);
}
