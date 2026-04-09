 module uim.platform.service.interfaces.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IBaseRepository(TEntity, TId) {
  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId);
 
  bool existsById(TId tenantId, id tenantId);
  TEntity findById(TId tenantId, id tenantId);

  void save(TEntity entity);
  void update(TEntity entity);
  void remove(TId tenantId, id tenantId);
}

interface ITenantRepository(TEntity, TId) {
  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId);
 
  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);

  void save(TEntity entity);
  void save(TenantId tenantId, TEntity entity);
  void update(TEntity entity);
  void remove(TenantId tenantId, TId id);
}