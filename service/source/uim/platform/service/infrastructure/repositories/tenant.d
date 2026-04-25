module uim.platform.service.infrastructure.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class TenantRepository(TEntity, TId) {
  protected TEntity[TId][TenantId] store;

  this() {
    initialize();
  }

  bool initialize(Json initData = Json(null)) {
    if (!super.initialize(initData)) {
      return false;
    }

    return true;
  }

  // #region ById
  bool existsById(TId id) {
    return findAll().any!(e => e.id == id);
  }

  bool existsAllById(TId[] ids) {
    return ids.all!(id => existsById(id));
  }

  bool existsById(TenantId tenantId, TId id) {
    return existsByTenant(tenantId) && (id in store[tenantId]);
  }

  TEntity findById(TenantId tenantId, TId id) {
    return existsById(tenantId, id) ? store[tenantId][id] : TEntity.init;
  }

  TEntity[] findAllById(TenantId tenantId, TId[] ids) {
    return ids.map!(id => findById(tenantId, id)).array;
  }

  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false) {
    if (existsById(tenantId, id)) {
      store[tenantId].remove(id);

      if (deleteTenantIfEmpty && store[tenantId].empty) {
        store.remove(tenantId);
      }
    }
  }

  void removeAllById(TenantId tenantId, TId[] ids, bool deleteTenantIfEmpty = false) {
    ids.each!(id => removeById(tenantId, id, deleteTenantIfEmpty));
  }
  // #endregion ById

  size_t countAll() {
    size_t count = 0;
    foreach (tenantId, items; findAll) {
      count += items.length;
    }
    return count;
  }

  TEntity[] findAll(uint offset = 0, uint limit = 0) {
    TEntity[] allItems;
    uint idx;
    foreach (tenantId, items; findAll) {
      foreach (item; items.values.array) {
        if (idx >= offset && (limit == 0 || allItems.length < limit))
          allItems ~= item;
        idx++;
      }
    }
    return allItems;
  }

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store ? true : false;
  }

  TEntity[] filterByTenant(TEntity[] items, TenantId tenantId) {
    return items.filter!(e => e.tenantId == tenantId).array;
  }

  TEntity[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 0) {
    if (!existsByTenant(tenantId)) {
      return null;
    }

    TEntity[] allItems;
    uint idx;
    foreach (item; store[tenantId].values.array) {
      if (idx >= offset && (limit == 0 || allItems.length < limit))
        allItems ~= item;
      idx++;
    }
    return allItems;
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

  void saveAll(TEntity[] items) {
    items.each!(item => save(item));
  }

  void update(TEntity item) {
    if (existsById(item.tenantId, item.id)) {
      store[item.tenantId][item.id] = item;
    }
  }

  void updateAll(TEntity[] items) {
    items.each!(item => update(item));
  }

  void remove(TEntity item, bool deleteTenantIfEmpty = false) {
    removeById(item.tenantId, item.id, deleteTenantIfEmpty);
  }

  void removeAll(TEntity[] items, bool deleteTenantIfEmpty = false) {
    items.each!(item => remove(item, deleteTenantIfEmpty));
  }
}
/// TODO: 
// unittest {  
//   import uim.platform.service.domain.ports.repositories.tenant;
//   import uim.platform.service.domain.entities.tenant;

//   void testTenantRepository() {
//     auto repo = new TenantRepository!(Tenant, TenantId)();

//     auto tenant1 = Tenant(TenantId("tenant1"), "Tenant One");
//     auto tenant2 = Tenant(TenantId("tenant2"), "Tenant Two");

//     repo.save(tenant1);
//     repo.save(tenant2);

//     assert(repo.existsById(tenant1.tenantId, tenant1.id));
//     assert(repo.existsById(tenant2.tenantId, tenant2.id));

//     auto foundTenant1 = repo.findById(tenant1.tenantId, tenant1.id);
//     assert(foundTenant1.name == "Tenant One");

//     auto tenants = repo.findByTenant(tenant1.tenantId);
//     assert(tenants.length == 1);
//     assert(tenants[0].name == "Tenant One");

//     repo.removeById(tenant1.tenantId, tenant1.id);
//     assert(!repo.existsById(tenant1.tenantId, tenant1.id));

//     repo.removeByTenant(tenant2.tenantId);
//     assert(!repo.existsByTenant(tenant2.tenantId));
//   }
// }
