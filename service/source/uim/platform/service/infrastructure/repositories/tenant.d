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
  
  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false) {
     if (existsById(tenantId, id)) {
      store[tenantId].remove(id);
      
      if (deleteTenantIfEmpty && store[tenantId].empty) {
        store.remove(tenantId);
      }
    }
  }

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store ? true : false;
  }

  TEntity[] findByTenant(TenantId tenantId) {
    return existsByTenant(tenantId) ? store[tenantId].values.array : null;
  }

  void removeByTenant(TenantId tenantId, bool deleteTenantIfEmpty = false) {
    return findByTenant(tenantId).each!(e => remove(e, deleteTenantIfEmpty));
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

  void remove(TEntity item, bool deleteTenantIfEmpty = false) {
    removeById(item.tenantId, item.id, deleteTenantIfEmpty);
  }

}
///
unittest {  
  import uim.platform.service.domain.ports.repositories.tenant;
  import uim.platform.service.domain.entities.tenant;

  void testTenantRepository() {
    auto repo = new TenantRepository!(Tenant, TenantId)();

    auto tenant1 = Tenant(TenantId("tenant1"), "Tenant One");
    auto tenant2 = Tenant(TenantId("tenant2"), "Tenant Two");

    repo.save(tenant1);
    repo.save(tenant2);

    assert(repo.existsById(tenant1.tenantId, tenant1.id));
    assert(repo.existsById(tenant2.tenantId, tenant2.id));

    auto foundTenant1 = repo.findById(tenant1.tenantId, tenant1.id);
    assert(foundTenant1.name == "Tenant One");

    auto tenants = repo.findByTenant(tenant1.tenantId);
    assert(tenants.length == 1);
    assert(tenants[0].name == "Tenant One");

    repo.removeById(tenant1.tenantId, tenant1.id);
    assert(!repo.existsById(tenant1.tenantId, tenant1.id));

    repo.removeByTenant(tenant2.tenantId);
    assert(!repo.existsByTenant(tenant2.tenantId));
  }
}