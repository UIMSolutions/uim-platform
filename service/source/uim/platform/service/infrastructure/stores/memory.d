module uim.platform.service.infrastructure.stores.memory;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

class MemoryTenantStore(TEntity, TId) : TenantStore!(TEntity, TId) {

    TEntity[TId][TenantId] entities;

    bool existsTenant(TenantId tenantId) {
        return (tenantId in entities);
    }

    void createTenant(TenantId tenantId) {
        if (!existsTenant(tenantId)) {
            TEntity[TId] newEntityMap;
            entities[tenantId] = newEntityMap;
        }
    }

    TEntity[TId] getEntities(TenantId tenantId) {
        if (existsTenant(tenantId)) {
            return entities[tenantId];
        }
        return null; // or throw an exception
    }

    void removeTenant(TenantId tenantId) {
        if (existsTenant(tenantId)) {
            entities.remove(tenantId);
        }
    }
}