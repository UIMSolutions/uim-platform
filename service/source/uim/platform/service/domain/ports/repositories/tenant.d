module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface ITenantRepository(TEntity, TId) {

  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);
  void removeById(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false);

  TEntity[] findAll();

  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId);
  void removeByTenant(TenantId tenantId, bool deleteTenantIfEmpty = false);

  void save(TEntity item);
  void update(TEntity item);
  void remove(TEntity item, bool deleteTenantIfEmpty = false);

}
