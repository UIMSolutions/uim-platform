module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

interface ITentRepository(TEntity, TId) : IBaseRepository!TEntity /* : IIdRepository!(TEntity, TId) */ {
  
  // #region byTenant
  bool isTenantEmpty(TenantId tenantId);
  void createTenant(TenantId tenantId);
  TenantId[] findAllTenants();
  bool existsByTenant(TenantId tenantId);
  size_t countByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0);
  void removeByTenant(TenantId tenantId);  
  // #endregion byTenant

  // #region byId  
  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);
  void removeById(TenantId tenantId, TId id);

  bool existsAllById(TenantId tenantId, TId[] ids);
  TEntity[] findAllById(TenantId tenantId, TId[] ids);
  void removeAllById(TenantId tenantId, TId[] ids);
  // #endregion byId  

}
