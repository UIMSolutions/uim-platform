module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface ITenantRepository(TEntity, TId) : IIdRepository!(TEntity, TId) {
  
  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);
  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false);
  
  bool existsAllById(TenantId tenantId, TId[] ids);  
  TEntity[] findAllById(TenantId tenantId, TId[] ids);
  void removeAllById(TenantId tenantId, TId[] ids, bool deleteTenantIfEmpty = false);
  
  bool isTenantEmpty(TenantId tenantId);
  bool existsByTenant(TenantId tenantId);
  size_t countByTenant(TenantId tenantId);
  TEntity[] filterByTenant(TEntity[] items, TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 0);
  void removeByTenant(TenantId tenantId, bool deleteTenantIfEmpty = false);

}
