module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface ITenantRepository(TEntity, TId) {

  bool existsById(TenantId tenantId, TId id);
  bool existsAllById(TenantId tenantId, TId[] ids);  
  
  TEntity findById(TenantId tenantId, TId id);
  TEntity[] findAllById(TenantId tenantId, TId[] ids);
  
  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false);
  void removeAllById(TenantId tenantId, TId[] ids, bool deleteTenantIfEmpty = false);

  size_t countAll();
  TEntity[] findAll(size_t offset = 0, size_t limit = 0);

  bool existsByTenant(TenantId tenantId);

  size_t countByTenant(TenantId tenantId);
  TEntity[] filterByTenant(TEntity[] items, TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 0);
  void removeByTenant(TenantId tenantId, bool deleteTenantIfEmpty = false);

  void save(TEntity item);
  void saveAll(TEntity[] items);

  void update(TEntity item);
  void updateAll(TEntity[] items);

  void remove(TEntity item, bool deleteTenantIfEmpty = false);
  void removeAll(TEntity[] items, bool deleteTenantIfEmpty = false);

}
