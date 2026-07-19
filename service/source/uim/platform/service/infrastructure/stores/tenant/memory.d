module uim.platform.service.infrastructure.stores.tenant.memory;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class MemoryTenantStore(TEntity, TId) : ITenantStore!(TEntity, TId) {
    this() {
        initialize();
    }

    bool initialize(Json initData = Json(null)) {
        // if (!super.initialize(initData)) {
        //     return false;
        // }

        return true;
    }

    protected TEntity[TId][TenantId] _entities;

    // #region exists
    bool exists(TenantId tenantId) {
        return tenantId in _entities ? true : false;
    }

    bool exists(TenantId tenantId, TId id) {
        return exists(tenantId) && id in _entities[tenantId];
    }

    bool exists(TEntity entity) {
        auto tenantId = entity.tenantId;
        auto id = entity.id;
        return exists(tenantId, id);
    }
    // #endregion exists

    // #region count
    size_t count(TenantId tenantId) {
        if (exists(tenantId)) {
            return _entities[tenantId].length;
        }
        return 0;
    }

    size_t count(TenantId tenantId, bool delegate(TEntity) @safe predicate) {
        if (!exists(tenantId))
            return 0;
        auto entities = filter(_entities[tenantId].byValue.array, predicate);
        return entities.length;
    }
    // #endregion count

    bool isEmpty(TenantId tenantId) {
        return count(tenantId) == 0;
    }

    // #region filter
    TEntity[] filter(TEntity[] entities, bool delegate(TEntity) @safe predicate) {
        return entities.filter!((TEntity entity) => predicate(entity)).array;
    }
    // #endregion filter

    // #region find
    TEntity[] find(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        if (exists(tenantId)) {
            auto entities = _entities[tenantId].byValue.array;
            return limit == 0
                ? entities.skip(offset) : entities.skip(offset).limit(limit);
        }
        return null;
    }

    TEntity find(TenantId tenantId, TId id) {
        if (exists(tenantId, id)) {
            return _entities[tenantId][id];
        }
        return TEntity.init;
    }

    void save(TEntity entity) {
        auto tenantId = entity.tenantId;
        auto id = entity.id;
        if (!exists(tenantId)) {
            TEntity[TId] newEntities;
            _entities[tenantId] = newEntities;
        }
        _entities[tenantId][id] = entity;
    }

    void save(TEntity[] entities) {
        entities.each!(entity => save(entity));
    }

    void update(TEntity entity) {
        auto tenantId = entity.tenantId;
        auto id = entity.id;
        if (exists(tenantId, id)) {
            _entities[tenantId][id] = entity;
        }
    }

    void update(TEntity[] entities) {
        entities.each!(entity => update(entity));
    }

    // #region remove
    void remove(TenantId tenantId) {
        if (exists(tenantId)) {
            _entities.remove(tenantId);
        }
    }

    void remove(TenantId tenantId, TId id) {
        if (exists(tenantId, id)) {
            _entities[tenantId].remove(id);
        }
    }

    void remove(TEntity entity) {
        if (entity.isNull)
            return; // Do not remove null entities

        auto tenantId = entity.tenantId;
        auto id = entity.id;
        remove(tenantId, id);
    }

    void remove(TEntity[] entities) {
        entities.each!(entity => remove(entity));
    }
    // #endregion remove
}
///
unittest {
    auto store = new MemoryTenantStore!(User, UserId)();

    auto tenantId = TenantId("tenant1");
    auto user1 = User(tenantId, UserId("user1"));
    user1.displayName = "User 1";
    auto user2 = User(tenantId, UserId("user2"));
    user2.displayName = "User 2";

    store.save(user1);
    store.save(user2);
    // writeln("Saved users: ", store.count(tenantId));

    assert(store.exists(user1.tenantId));
    assert(store.exists(user2.tenantId));

    assert(store.count(user1.tenantId) == 2);
    assert(store.count(user2.tenantId) == 2);

    auto foundUser1 = store.find(user1.tenantId, user1.id);
    assert(foundUser1 == user1);

    store.remove(user1);
    assert(!store.exists(user1));
}
