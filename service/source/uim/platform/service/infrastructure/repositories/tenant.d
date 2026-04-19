module uim.platform.service.infrastructure.repositories.tenant;

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

  void save(TEntity item) {
    if (!existsByTenant(item.tenantId)) {
      TEntity[TId] entities;
      store[item.tenantId] = entities;
    } 
    store[item.tenantId][item.id] = item;
  }

  void update(TEntity item) {
    if (existsById(item.tenantId, item.id)) {
      store[item.tenantId][item.id] = item;
    }
  }

  void remove(TEntity item) {
    if (existsById(item.tenantId, item.id)) {
      store[item.tenantId].remove(item.id);
    }
  }

  void remove(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false) {
     if (existsById(tenantId, id)) {
      store[tenantId].remove(id);
      
      if (deleteTenantIfEmpty && store[tenantId].empty) {
        store.remove(tenantId);
      }
    }
  }
}
