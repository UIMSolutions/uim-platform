module uim.platform.service.infrastructure.stores.tenant.memory;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

class MemoryTenantStore(TEntity, TId) : ITenantStore!(TEntity, TId) {
    this() {
        initialize();
    }

    override bool initialize(Json initData = Json(null)) {
        if (!super.initialize(initData)) {
            return false;
        }

        return true;
    }

    protected TEntity[TId][TenantId] _entities;

    // #region exists
    bool exists(TenantId tenantId) {
        return tenantId in _entities;
    }

    bool existsId(TenantId tenantId, TId id) {
        return exists(tenantId) && id in _entities[tenantId];
    }
    // #endregion exists

    // #region count
    size_t count(TenantId tenantId) {
        if (exists(tenantId)) {
            return _entities[tenantId].length;
        }
        return 0;
    }

    size_t count(TenantId tenantId, bool delegate(TEntity) predicate) {
        return exists(tenantId)
            ? _entities[tenantId].byValue.count!(predicate) : 0;
    }
    // #endregion count

    bool isEmpty(TenantId tenantId) {
        return countAll(tenantId) == 0;
    }

    // #region find
    TEntity[] filter(TEntity[] entities, bool delegate(TEntity) predicate) {
        return entities.filter!(predicate);
    }
    // #endregion find

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
        if (existsId(tenantId, id)) {
            return _entities[tenantId][id];
        }
        return TEntity.init;
    }

    TEntity create(TenantId tenantId) {
        auto entity = TEntity(tenantId);
        save(entity);
        return entity;
    }

    void save(TEntity entity) {
        auto tenantId = entity.tenantId;
        auto id = entity.id;
        if (!exists(tenantId)) {
            _entities[tenantId] = TEntity[TId]();
        }
        _entities[tenantId][id] = entity;
    }

    void save(TEntity[] entities) {
        entities.each!(entity => save(entity));
    }

    void update(TEntity entity) {
        auto tenantId = entity.tenantId;
        auto id = entity.id;
        if (existsId(tenantId, id)) {
            _entities[tenantId][id] = entity;
        }
    }

    void update(TEntity[] entities) {
        entities.each!(entity => update(entity));
    }

    // #region remove
    void remove(TenantId tenantId, TId id) {
        if (existsId(tenantId, id)) {
            _entities[tenantId].remove(id);
        }
    }

    void remove(TEntity entity) {
        auto tenantId = entity.tenantId;
        auto id = entity.id;
        remove(tenantId, id);
    }

    void remove(TEntity[] entities) {
        entities.each!(entity => remove(entity));
    }
    // #endregion remove
}
