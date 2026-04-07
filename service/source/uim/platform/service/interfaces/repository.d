 module uim.platform.service.interfaces.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IBaseRepository(TEntity, TId) {
  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId);
 
  bool existsId(TId id, TenantId tenantId);
  TEntity findById(TId id, TenantId tenantId);

  void save(TEntity entity);
  void update(TEntity entity);
  void remove(TId id, TenantId tenantId);
}