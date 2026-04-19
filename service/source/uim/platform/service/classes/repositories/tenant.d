module uim.platform.service.classes.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class TenantRepository(TEntity, TId) {
  protected TEntity[TId][TenantId] store;

  bool existsById(TenantId tenantId, TId id) {
    return existsByTenant(tenantId) && (id in store[tenantId]);
  }

  TEntity findById(TenantId tenantId, TId id) {
    return existsById(tenantId, id) ? store[tenantId][id] : TEntity.init;
  }

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store ? true : false;
  }

  TEntity[] findByTenant(TenantId tenantId) {
    return existsByTenant(tenantId) ? store[tenantId].values.array : null;
  }

  void save(TenantId tenantId, TEntity item) {
    if (!existsByTenant(tenantId)) {
      TEntity[TId] entities;
      store[tenantId] = entities;
    } 
    store[tenantId][item.id] = item;
  }

  void update(TenantId tenantId, TEntity item) {
    if (existsById(tenantId, item.id)) {
      store[tenantId][item.id] = item;
    }
  }

  void remove(TenantId tenantId, TId id) {
    if (existsById(tenantId, id)) {
      store[tenantId].remove(id);
    }
  }
}
