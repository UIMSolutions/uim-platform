module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface ITenantRepository(TEntity, TId) {

  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);
  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false);

  size_t countAll();
  TEntity[] findAll(uint offset = 0, uint limit = 0);

  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 0);
  void removeByTenant(TenantId tenantId, bool deleteTenantIfEmpty = false);

  void save(TEntity item);
  void save(TEntity[] items);

  void update(TEntity item);
  void update(TEntity[] items);

  void remove(TEntity item, bool deleteTenantIfEmpty = false);
  void remove(TEntity[] items, bool deleteTenantIfEmpty = false);

}
