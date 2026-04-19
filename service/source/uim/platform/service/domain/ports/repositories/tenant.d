module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface ITenantRepository(TEntity, TId) {
  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);

  bool existsByTenant(TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId);

  void save(TenantId tenantId, TEntity item);
  void save(TEntity item);

  void update(TEntity item);

  void remove(TEntity item, bool deleteTenantIfEmpty = false);
  void remove(TenantId tenantId, TId id, bool deleteTenantIfEmpty = false);
}
